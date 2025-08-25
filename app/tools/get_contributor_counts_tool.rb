class GetContributorCountsTool < BaseTool
  def self.description
    "Get contributor counts for PRs and issues"
  end

  def self.category
    "Contributors"
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
    contributor_stats = @client.repository_contributor_stats(host, owner, repo)
    return { error: "Contributor statistics not found" } unless contributor_stats
    
    {
      total_contributors: contributor_stats["total_contributors"],
      contributors_last_30_days: contributor_stats["contributors_last_30_days"],
      contributors_last_90_days: contributor_stats["contributors_last_90_days"],
      contributors_last_year: contributor_stats["contributors_last_year"]
    }
  end
end