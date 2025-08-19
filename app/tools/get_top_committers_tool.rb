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
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy)" },
        limit: { type: "number", description: "Number of top committers to return (default: 10)" }
      },
      required: ["repo_url"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    limit = arguments[:limit] || arguments["limit"] || 10

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      top_committers = @client.repository_top_committers("GitHub", owner, repo, limit: limit)
      
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
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end