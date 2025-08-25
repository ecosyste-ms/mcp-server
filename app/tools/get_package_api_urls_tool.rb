class GetPackageApiUrlsTool < BaseTool
  def self.description
    "Get ecosyste.ms JSON API URLs for package analysis"
  end

  def self.category
    "Package"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g. pkg:pypi/numpy)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["purl", "context"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    response = @client.lookup_by_purl(purl_string)
    return { error: "Package not found" } unless response
    
    # Extract registry and name for constructing API URLs
    registry = response["registry"]
    name = response["name"]
    encoded_name = CGI.escape(name)
    
    # Package-specific API URLs
    package_api_urls = {
      package_lookup: "https://packages.ecosyste.ms/api/v1/packages/lookup?purl=#{CGI.escape(purl_string)}",
      package_details: "https://packages.ecosyste.ms/api/v1/registries/#{registry}/packages/#{encoded_name}",
      package_versions: "https://packages.ecosyste.ms/api/v1/registries/#{registry}/packages/#{encoded_name}/versions",
      package_dependencies: "https://packages.ecosyste.ms/api/v1/registries/#{registry}/packages/#{encoded_name}/dependencies",
      package_dependents: "https://packages.ecosyste.ms/api/v1/registries/#{registry}/packages/#{encoded_name}/dependents",
      package_maintainers: "https://packages.ecosyste.ms/api/v1/registries/#{registry}/packages/#{encoded_name}/maintainers"
    }
    
    # Add vulnerability API URLs
    ecosystem = response["ecosystem"]
    if ecosystem
      package_api_urls[:vulnerabilities] = "https://advisories.ecosyste.ms/api/v1/advisories/lookup?purl=#{CGI.escape(purl_string)}"
    end
    
    # Add repository URLs if available
    if response["repository_url"] || response["tags_url"]
      repository_urls = {
        repository: response["repository_url"],
        repository_tags: response["tags_url"],
        repository_releases: response["releases_url"],
        repository_manifests: response["manifests_url"],
        repository_sbom: response["sbom_url"],
        repository_owner: response["owner_url"]
      }.compact
      
      package_api_urls.merge!(repository_urls) if repository_urls.any?
    end
    
    {
      purl: purl_string,
      package_name: name,
      registry: registry,
      ecosystem: ecosystem,
      api_urls: package_api_urls
    }
  end
end