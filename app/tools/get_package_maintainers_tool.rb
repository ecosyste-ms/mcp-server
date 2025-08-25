class GetPackageMaintainersTool < BaseTool
  def self.description
    "Get package maintainers list"
  end

  def self.category
    "Package"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g. pkg:pypi/requests)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["purl", "context"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    maintainers = @client.package_maintainers(purl_string)
    
    if maintainers && maintainers.any?
      {
        maintainers: maintainers.map do |maintainer|
          {
            login: maintainer["login"],
            name: maintainer["name"],
            email: maintainer["email"],
            role: maintainer["role"]
          }
        end
      }
    else
      { maintainers: [] }
    end
  end
end