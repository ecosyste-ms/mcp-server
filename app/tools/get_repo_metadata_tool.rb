class GetRepoMetadataTool < BaseTool
  def self.description
    "Get repository metadata (topics, language, license, default_branch)"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["repo_url", "context"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      repo_data = @client.repository_info("GitHub", owner, repo)
      return { error: "Repository not found" } unless repo_data
      
      {
        topics: repo_data["topics"],
        language: repo_data["language"],
        license: repo_data["license"],
        default_branch: repo_data["default_branch"],
        has_issues: repo_data["has_issues"],
        has_wiki: repo_data["has_wiki"],
        has_pages: repo_data["has_pages"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end