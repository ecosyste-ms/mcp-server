class GetPastYearActivityTool < BaseTool
  def self.description
    "Get past year issue and PR activity"
  end

  def self.category
    "Issues"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy)" },
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
      
      activity = @client.repository_past_year_activity("GitHub", owner, repo)
      return { error: "Activity data not found" } unless activity
      
      {
        issues_opened_last_year: activity["issues_opened_last_year"],
        issues_closed_last_year: activity["issues_closed_last_year"],
        pull_requests_opened_last_year: activity["pull_requests_opened_last_year"],
        pull_requests_merged_last_year: activity["pull_requests_merged_last_year"],
        commits_last_year: activity["commits_last_year"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end