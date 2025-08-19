class GetPackageBasicInfoTool < BaseTool
  def self.description
    "Get basic package information (id, name, ecosystem, description, homepage, licenses)"
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
    
    {
      id: response["id"],
      name: response["name"],
      ecosystem: response["ecosystem"],
      description: response["description"],
      homepage: response["homepage"],
      licenses: response["licenses"]
    }
  end
end