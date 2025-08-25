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
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy) or PURL (e.g. pkg:pypi/numpy, pkg:github/octobox/octobox, pkg:git/example/repo)" },
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

    # Extract host info for subsequent calls
    host = repo_lookup["host"]["name"]  # e.g. "GitHub"
    full_name = repo_lookup["full_name"]  # e.g. "owner/repo"
    owner, repo = full_name.split("/", 2) if full_name

    return { error: "Invalid repository format" } unless owner && repo

    # Make API call using lookup data
    activity = @client.repository_past_year_activity(host, owner, repo)
    
    if activity
      {
        issues_opened_last_year: activity["issues_opened_last_year"],
        issues_closed_last_year: activity["issues_closed_last_year"],
        pull_requests_opened_last_year: activity["pull_requests_opened_last_year"],
        pull_requests_merged_last_year: activity["pull_requests_merged_last_year"],
        commits_last_year: activity["commits_last_year"]
      }
    else
      {
        issues_opened_last_year: nil,
        issues_closed_last_year: nil,
        pull_requests_opened_last_year: nil,
        pull_requests_merged_last_year: nil,
        commits_last_year: nil,
        message: "No activity data available for this repository"
      }
    end
  end
end