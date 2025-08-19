class GetRepoChangelogTool < BaseTool
  def self.description
    "Get repository changelog with parsed version entries using archives API"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" },
        version: { type: "string", description: "Optional specific version to get changes for (e.g., '4.0.4')" }
      },
      required: ["repo_url"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    version = arguments[:version] || arguments["version"]
    return { error: "Repository URL required" } unless repo_url

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      changelog = @client.repository_changelog("GitHub", owner, repo, version)
      
      {
        changelog: changelog,
        version: version,
        exists: !changelog.nil?
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end