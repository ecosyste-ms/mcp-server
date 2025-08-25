class GetPackageUrlsTool < BaseTool
  def self.description
    "Get ecosyste.ms URLs for package analysis and exploration"
  end

  def self.category
    "Package"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g. pkg:pypi/numpy)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["purl", "context"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    response = @client.lookup_by_purl(purl_string)
    return { error: "Package not found" } unless response
    
    base_url = "https://packages.ecosyste.ms"
    ecosystem = response["ecosystem"]
    name = response["name"]
    
    {
      package_url: "#{base_url}/#{ecosystem}/#{name}",
      versions_url: "#{base_url}/#{ecosystem}/#{name}/versions",
      dependencies_url: "#{base_url}/#{ecosystem}/#{name}/dependencies",
      dependents_url: "#{base_url}/#{ecosystem}/#{name}/dependents"
    }
  end
end