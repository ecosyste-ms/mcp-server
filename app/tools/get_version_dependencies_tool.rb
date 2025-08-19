class GetVersionDependenciesTool < BaseTool
  def self.description
    "Get dependencies for a specific version"
  end

  def self.category
    "Version"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL with version (e.g. pkg:cargo/rand@0.9.2)" }
      },
      required: ["purl"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    parts = purl_string.split('@')
    return { error: "Version required in PURL" } unless parts.length == 2
    
    package_purl, version = parts
    dependencies = @client.version_dependencies(package_purl, version)
    
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