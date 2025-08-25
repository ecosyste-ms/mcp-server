class GetRepoBasicInfoTool < BaseTool
  def self.description
    "Get repository basic info (id, full_name, owner, description, archived, fork)"
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
    
    # Check if this looks like a PURL (starts with pkg:)
    if repo_url.start_with?("pkg:")
      # Look up the package to get repository_url
      package_response = @client.lookup_by_purl(repo_url)
      return { error: "Package not found" } unless package_response
      
      repository_url = package_response["repository_url"]
      return { error: "No repository URL found for this package" } unless repository_url
      
      repo_url = repository_url
    end
    
    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup
    
    # Use the direct repository API URL from the lookup response
    repository_api_url = repo_lookup["repository_url"]
    return { error: "Repository API URL not available" } unless repository_api_url
    
    # Make API call using the direct URL
    repo_data = @client.fetch_external_api(repository_api_url)
    return { error: "Repository not found" } unless repo_data
    
    {
      id: repo_data["id"],
      full_name: repo_data["full_name"],
      owner: repo_data["owner"],
      description: repo_data["description"],
      archived: repo_data["archived"],
      fork: repo_data["fork"]
    }
  end
end