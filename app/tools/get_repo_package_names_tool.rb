class GetRepoPackageNamesTool < BaseTool
  def self.description
    "Get package names associated with a repository"
  end

  def self.category
    "Repository"
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

    # Ensure URL has proper protocol
    repo_url = "https://#{repo_url}" unless repo_url.start_with?("http")
    
    packages = @client.packages_by_repository_url(repo_url)
    
    if packages && packages.is_a?(Array)
      package_names = packages.map do |pkg|
        {
          name: pkg["name"],
          registry: pkg["registry"],
          ecosystem: pkg["ecosystem"],
          purl: pkg["purl"]
        }
      end
      
      {
        repository_url: repo_url,
        packages: package_names,
        packages_count: package_names.length
      }
    else
      { 
        repository_url: repo_url,
        packages: [],
        packages_count: 0
      }
    end
  end
end