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
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy)" }
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
      
      contributor_stats = @client.repository_contributor_stats("GitHub", owner, repo)
      return { error: "Contributor statistics not found" } unless contributor_stats
      
      {
        total_contributors: contributor_stats["total_contributors"],
        contributors_last_30_days: contributor_stats["contributors_last_30_days"],
        contributors_last_90_days: contributor_stats["contributors_last_90_days"],
        contributors_last_year: contributor_stats["contributors_last_year"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end