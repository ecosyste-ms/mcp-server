class GetIssueCountsTool < BaseTool
  def self.description
    "Get issue and PR counts (total, closed)"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
      },
      required: ["repo_url"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      issue_stats = @client.repository_issue_stats("GitHub", owner, repo)
      return { error: "Issue statistics not found" } unless issue_stats
      
      {
        total_issues: issue_stats["total_issues"],
        closed_issues: issue_stats["closed_issues"],
        open_issues: issue_stats["open_issues"],
        total_pull_requests: issue_stats["total_pull_requests"],
        closed_pull_requests: issue_stats["closed_pull_requests"],
        open_pull_requests: issue_stats["open_pull_requests"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end