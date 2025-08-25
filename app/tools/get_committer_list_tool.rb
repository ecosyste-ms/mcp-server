class GetCommitterListTool < BaseTool
  def self.description
    "Get complete list of committers with commit counts"
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

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      committers = @client.repository_committers("GitHub", owner, repo)
      
      if committers && committers.any?
        {
          committers: committers.map do |committer|
            {
              login: committer["login"],
              name: committer["name"],
              email: committer["email"],
              commits: committer["commits"],
              first_commit_at: committer["first_commit_at"],
              last_commit_at: committer["last_commit_at"]
            }
          end,
          total_committers: committers.length
        }
      else
        { committers: [], total_committers: 0 }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end