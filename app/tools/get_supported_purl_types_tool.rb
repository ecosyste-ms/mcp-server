class GetSupportedPurlTypesTool < BaseTool
  def self.description
    "Get list of all supported PURL types from registries and git platforms"
  end

  def self.category
    "Registry"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["context"]
    }
  end

  def call(arguments)
    # Get all registries from the API
    registries = @client.registry_list
    
    # Extract PURL types from registries
    registry_purl_types = []
    if registries && registries.is_a?(Array)
      registry_purl_types = registries.map { |reg| reg["purl_type"] }.compact.uniq.sort
    end
    
    # Add git-related PURL types that aren't in registries
    git_purl_types = %w[git github gitlab bitbucket forgejo gitea codeberg]
    
    # Combine and deduplicate
    all_purl_types = (registry_purl_types + git_purl_types).uniq.sort
    
    # Separate into categories for clarity
    package_manager_types = registry_purl_types
    git_platform_types = git_purl_types
    
    {
      supported_purl_types: all_purl_types,
      total_count: all_purl_types.length,
      categories: {
        package_managers: {
          types: package_manager_types,
          count: package_manager_types.length,
          description: "Package manager registries from ecosyste.ms"
        },
        git_platforms: {
          types: git_platform_types,
          count: git_platform_types.length,
          description: "Git hosting platforms and version control systems"
        }
      }
    }
  end
end