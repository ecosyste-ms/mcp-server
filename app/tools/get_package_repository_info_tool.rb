class GetPackageRepositoryInfoTool < BaseTool
  def self.description
    "Get repository URL and social metrics (stars, forks)"
  end

  def self.category
    "Package"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g. pkg:pypi/numpy)" }
      },
      required: ["purl"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    response = @client.lookup_by_purl(purl_string)
    return { error: "Package not found" } unless response
    
    {
      repository_url: response["repository_url"],
      stars: response["stars"],
      forks: response["forks"]
    }
  end
end