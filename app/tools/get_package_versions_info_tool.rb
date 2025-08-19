class GetPackageVersionsInfoTool < BaseTool
  def self.description
    "Get version count and latest release info"
  end

  def self.category
    "Version"
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
      versions_count: response["versions_count"],
      latest_release_number: response["latest_release_number"],
      latest_release_published_at: response["latest_release_published_at"]
    }
  end
end