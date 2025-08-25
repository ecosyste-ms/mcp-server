class GetFundingLinksTool < BaseTool
  def self.description
    "Get funding links for a package"
  end

  def self.category
    "Package"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g. pkg:npm/express)" },
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
    
    {
      package_name: response["name"],
      funding_links: response["funding_links"] || []
    }
  end
end