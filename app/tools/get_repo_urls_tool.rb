class GetRepoUrlsTool < BaseTool
  def self.description
    "Get ecosyste.ms URLs for repository analysis across all platforms"
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

    # Return URLs directly from the lookup response
    {
      repository_url: repo_lookup["repository_url"],
      tags_url: repo_lookup["tags_url"],
      releases_url: repo_lookup["releases_url"],
      manifests_url: repo_lookup["manifests_url"],
      owner_url: repo_lookup["owner_url"],
      scorecard_url: repo_lookup["scorecard_url"]
    }.compact
  end
end