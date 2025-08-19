class GetPackageDatesTool < BaseTool
  def self.description
    "Get package creation and update dates"
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
      created_at: response["created_at"],
      updated_at: response["updated_at"],
      first_release_published_at: response["first_release_published_at"]
    }
  end
end