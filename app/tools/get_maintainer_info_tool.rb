class GetMaintainerInfoTool < BaseTool
  def self.description
    "Get maintainer lists (all-time and active)"
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
      
      maintainers = @client.repository_maintainers("GitHub", owner, repo)
      
      if maintainers && maintainers.any?
        {
          maintainers: maintainers.map do |maintainer|
            {
              login: maintainer["login"],
              name: maintainer["name"],
              email: maintainer["email"],
              commits_count: maintainer["commits_count"],
              first_commit_at: maintainer["first_commit_at"],
              last_commit_at: maintainer["last_commit_at"]
            }
          end
        }
      else
        { maintainers: [] }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end