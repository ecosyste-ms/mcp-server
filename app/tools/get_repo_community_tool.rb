class GetRepoCommunityTool < BaseTool
  def self.description
    "Get community metrics (stars, forks, subscribers, open_issues)"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy)" }
      },
      required: ["repo_url"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    # Parse GitHub URL to get owner/repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      repo_data = @client.repository_info("GitHub", owner, repo)
      return { error: "Repository not found" } unless repo_data
      
      {
        stars: repo_data["stargazers_count"],
        forks: repo_data["forks_count"],
        subscribers: repo_data["subscribers_count"],
        open_issues: repo_data["open_issues_count"],
        watchers: repo_data["watchers_count"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end