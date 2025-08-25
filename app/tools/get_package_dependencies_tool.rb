class GetPackageDependenciesTool < BaseTool
  def self.description
    "Get dependencies for latest version of a package"
  end

  def self.category
    "Dependencies"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL without version (e.g. pkg:cargo/rand)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["purl", "context"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    dependencies = @client.package_dependencies(purl_string)
    
    if dependencies && dependencies.any?
      {
        dependencies: dependencies.map do |dep|
          {
            name: dep["name"],
            requirement: dep["requirement"],
            kind: dep["kind"],
            optional: dep["optional"],
            ecosystem: dep["ecosystem"]
          }
        end
      }
    else
      { dependencies: [] }
    end
  end
end