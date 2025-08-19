class GetPackageVersionNumbersTool < BaseTool
  def self.description
    "Get simple list of version numbers for a package"
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

    version_numbers = @client.package_version_numbers(purl_string)
    
    {
      version_numbers: version_numbers || []
    }
  end
end