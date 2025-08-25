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
    committers = @client.repository_committers(host, owner, repo)
    
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
  end
end