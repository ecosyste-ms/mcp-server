class GetDependentPackagesTool < BaseTool
  def self.description
    "Get packages that depend on this package"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" },
        page: { type: "number", description: "Page number (default: 1)" }
      },
      required: ["purl"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    page = arguments[:page] || arguments["page"] || 1
    
    dependents = @client.dependent_packages(purl_string, page: page)
    
    if dependents && dependents.any?
      {
        dependents: dependents.map do |dep|
          {
            name: dep["name"],
            ecosystem: dep["ecosystem"],
            description: dep["description"],
            stars: dep["stars"],
            dependents_count: dep["dependents_count"]
          }
        end
      }
    else
      { dependents: [] }
    end
  end
end