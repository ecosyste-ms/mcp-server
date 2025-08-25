class GetRepoActivityTool < BaseTool
  def self.description
    "Get repository activity metrics (pushed_at, size, last_synced_at)"
  end

  def self.category
    "Repository"
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
    
    # Use the direct repository API URL from the lookup response
    repository_api_url = repo_lookup["repository_url"]
    return { error: "Repository API URL not available" } unless repository_api_url
    
    # Make API call using the direct URL
    activity = @client.fetch_external_api(repository_api_url)
    return { error: "Repository not found" } unless activity
    
    {
      pushed_at: activity["pushed_at"],
      size: activity["size"],
      last_synced_at: activity["last_synced_at"],
      status: activity["status"]
    }
  end
end