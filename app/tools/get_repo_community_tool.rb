class GetRepoCommunityTool < BaseTool
  def self.description
    "Get community metrics (stars, forks, subscribers, open_issues)"
  end

  def self.category
    "Repository"
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
    repo_data = @client.repository_info(host, owner, repo)
    return { error: "Repository not found" } unless repo_data
    
    {
      stars: repo_data["stargazers_count"],
      forks: repo_data["forks_count"],
      subscribers: repo_data["subscribers_count"],
      open_issues: repo_data["open_issues_count"],
      watchers: repo_data["watchers_count"]
    }
  end
end