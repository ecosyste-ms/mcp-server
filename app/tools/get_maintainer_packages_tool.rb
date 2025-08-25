class GetMaintainerPackagesTool < BaseTool
  def self.description
    "Get packages maintained by a specific maintainer"
  end

  def self.category
    "Maintainer"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        registry: { type: "string", description: "Registry name (e.g. rubygems.org, npmjs.org)" },
        maintainer: { type: "string", description: "Maintainer username" }
      },
      required: ["registry", "maintainer"]
    }
  end

  def call(arguments)
    registry = arguments[:registry] || arguments["registry"]
    maintainer = arguments[:maintainer] || arguments["maintainer"]
    
    return { error: "Registry required" } unless registry
    return { error: "Maintainer required" } unless maintainer

    packages = @client.maintainer_packages(registry, maintainer)
    
    if packages && packages.is_a?(Array)
      {
        registry: registry,
        maintainer: maintainer,
        packages: packages,
        packages_count: packages.length
      }
    else
      {
        registry: registry,
        maintainer: maintainer,
        packages: [],
        packages_count: 0
      }
    end
  end
end