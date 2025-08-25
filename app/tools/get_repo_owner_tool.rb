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

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      repo_data = @client.repository_info("GitHub", owner, repo)
      return { error: "Repository not found" } unless repo_data
      
      owner_data = repo_data["owner"]
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
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end