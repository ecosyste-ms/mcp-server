class GetPackageUrlsTool < BaseTool
  def self.description
    "Get ecosyste.ms URLs for package analysis and exploration"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      },
      required: ["purl"]
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