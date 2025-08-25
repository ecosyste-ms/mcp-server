class GetTopCommittersTool < BaseTool
  def self.description
    "Get top N committers by commit count"
  end

  def self.category
    "Contributors"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy) or PURL (e.g. pkg:pypi/numpy, pkg:github/octobox/octobox, pkg:git/example/repo)" },
        limit: { type: "number", description: "Number of top committers to return (default: 10)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["repo_url", "context"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    limit = arguments[:limit] || arguments["limit"] || 10

    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup

    # Extract host info for subsequent calls
    host = repo_lookup["host"]["name"]  # e.g. "GitHub"
    full_name = repo_lookup["full_name"]  # e.g. "owner/repo"
    owner, repo = full_name.split("/", 2) if full_name

    return { error: "Invalid repository format" } unless owner && repo

    # Make API call using lookup data
    top_committers = @client.repository_top_committers(host, owner, repo, limit: limit)
    
    if top_committers && top_committers.any?
      {
        top_committers: top_committers.map do |committer|
          {
            login: committer["login"],
            name: committer["name"],
            commits: committer["commits"],
            percentage: committer["percentage"]
          }
        end,
        limit: limit
      }
    else
      { top_committers: [], limit: limit }
    end
  end
end