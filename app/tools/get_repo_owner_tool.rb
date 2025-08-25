class GetRepoOwnerTool < BaseTool
  def self.description
    "Get repository owner information using ecosyste.ms repos API"
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

    # Use the direct owner API URL from the lookup response
    owner_api_url = repo_lookup["owner_url"]
    return { error: "Owner API URL not available" } unless owner_api_url

    # Make API call using the direct URL
    owner_data = @client.fetch_external_api(owner_api_url)
    return { error: "Owner information not found" } unless owner_data
    
    {
      login: owner_data["login"],
      name: owner_data["name"],
      type: owner_data["type"],
      avatar_url: owner_data["avatar_url"],
      html_url: owner_data["html_url"],
      public_repos: owner_data["public_repos"],
      followers: owner_data["followers"],
      following: owner_data["following"]
    }
  end
end