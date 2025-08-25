class GetIssueCountsTool < BaseTool
  def self.description
    "Get issue and PR counts (total, closed)"
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

    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup

    # Extract host info for subsequent calls
    host = repo_lookup["host"]["name"]  # e.g. "GitHub"
    full_name = repo_lookup["full_name"]  # e.g. "owner/repo"
    owner, repo = full_name.split("/", 2) if full_name

    return { error: "Invalid repository format" } unless owner && repo

    # Make API call using lookup data
    issue_stats = @client.repository_issue_stats(host, owner, repo)
    return { error: "Issue statistics not found" } unless issue_stats
    
    {
      total_issues: issue_stats["total_issues"],
      closed_issues: issue_stats["closed_issues"],
      open_issues: issue_stats["open_issues"],
      total_pull_requests: issue_stats["total_pull_requests"],
      closed_pull_requests: issue_stats["closed_pull_requests"],
      open_pull_requests: issue_stats["open_pull_requests"]
    }
  end
end