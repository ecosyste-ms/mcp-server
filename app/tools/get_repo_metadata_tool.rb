class GetRepoMetadataTool < BaseTool
  def self.description
    "Get repository metadata (topics, language, license, default_branch)"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" },
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
      topics: repo_data["topics"],
      language: repo_data["language"],
      license: repo_data["license"],
      default_branch: repo_data["default_branch"],
      has_issues: repo_data["has_issues"],
      has_wiki: repo_data["has_wiki"],
      has_pages: repo_data["has_pages"]
    }
  end
end