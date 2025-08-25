class GetVersionInfoTool < BaseTool
  def self.description
    "Get specific version metadata (published_at, downloads, author)"
  end

  def self.category
    "Version"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL with version (e.g. pkg:pypi/numpy@1.24.0)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["purl", "context"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    # Parse version from PURL
    parts = purl_string.split('@')
    return { error: "Version required in PURL (e.g. pkg:pypi/numpy@1.24.0)" } unless parts.length == 2
    
    package_purl, version = parts
    response = @client.version_info(package_purl, version)
    return { error: "Version not found" } unless response
    
    {
      version: response["version"],
      published_at: response["published_at"],
      downloads: response["downloads"],
      author: response["author"],
      description: response["description"]
    }
  end
end