class GetRepoChangelogTool < BaseTool
  def self.description
    "Get repository changelog with parsed version entries using archives API"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy)" },
        version: { type: "string", description: "Optional specific version to get changes for (e.g. '4.0.4')" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["repo_url", "context"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    version = arguments[:version] || arguments["version"]
    return { error: "Repository URL required" } unless repo_url

    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup

    # Try to use the direct changelog API URL from the lookup response if available
    changelog_api_url = repo_lookup["changelog_url"]
    
    if changelog_api_url
      # Add version parameter if provided
      changelog_url_with_params = version ? "#{changelog_api_url}?version=#{version}" : changelog_api_url
      # Make API call using the direct URL
      changelog = @client.fetch_external_api(changelog_url_with_params)
    else
      # Fall back to the original pattern if no direct URL is available
      host = repo_lookup["host"]["name"]
      full_name = repo_lookup["full_name"]
      owner, repo = full_name.split("/", 2) if full_name
      
      return { error: "Invalid repository format" } unless owner && repo
      
      changelog = @client.repository_changelog(host, owner, repo, version)
    end
    
    {
      changelog: changelog,
      version: version,
      exists: !changelog.nil?
    }
  end
end