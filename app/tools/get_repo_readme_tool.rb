class GetRepoReadmeTool < BaseTool
  def self.description
    "Get repository README content using archives API"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy) or PURL (e.g. pkg:pypi/numpy, pkg:github/octobox/octobox, pkg:git/example/repo)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["repo_url", "context"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup

    # Try to use the direct readme API URL from the lookup response if available
    readme_api_url = repo_lookup["readme_url"]
    
    if readme_api_url
      # Make API call using the direct URL
      readme = @client.fetch_external_api(readme_api_url)
    else
      # Fall back to the original pattern if no direct URL is available
      host = repo_lookup["host"]["name"]
      full_name = repo_lookup["full_name"]
      owner, repo = full_name.split("/", 2) if full_name
      
      return { error: "Invalid repository format" } unless owner && repo
      
      readme = @client.repository_readme(host, owner, repo)
    end
    
    {
      readme: readme,
      exists: !readme.nil?
    }
  end
end