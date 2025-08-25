class GetPackageDatesTool < BaseTool
  def self.description
    "Get package creation and update dates"
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
    
    {
      created_at: response["created_at"],
      updated_at: response["updated_at"],
      first_release_published_at: response["first_release_published_at"]
    }
  end
end