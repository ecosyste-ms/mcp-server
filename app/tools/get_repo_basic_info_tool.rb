class GetRepoBasicInfoTool < BaseTool
  def self.description
    "Get repository basic info (id, full_name, owner, description, archived, fork)"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy) or PURL (e.g., pkg:pypi/numpy)" }
      },
      required: ["repo_url"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url
    
    # Check if this looks like a PURL (starts with pkg:)
    if repo_url.start_with?("pkg:")
      # Look up the package to get repository_url
      package_response = @client.lookup_by_purl(repo_url)
      return { error: "Package not found" } unless package_response
      
      repository_url = package_response["repository_url"]
      return { error: "No repository URL found for this package" } unless repository_url
      
      repo_url = repository_url
    end
    
    # Parse GitHub URL to get owner/repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      repo_data = @client.repository_info("GitHub", owner, repo)
      return { error: "Repository not found" } unless repo_data
      
      {
        id: repo_data["id"],
        full_name: repo_data["full_name"],
        owner: repo_data["owner"],
        description: repo_data["description"],
        archived: repo_data["archived"],
        fork: repo_data["fork"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end