class GetRelatedPackagesTool < BaseTool
  def self.description
    "Get packages related to this package (dependencies, dependents, similar packages)"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g., pkg:npm/react)" },
        page: { type: "number", description: "Page number (default: 1)" }
      },
      required: ["purl"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    page = arguments[:page] || arguments["page"] || 1
    
    related = @client.related_packages(purl_string, page: page)
    
    {
      related_packages: related || []
    }
  end
end