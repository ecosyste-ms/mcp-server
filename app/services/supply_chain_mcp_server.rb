require 'fast_mcp'

class SupplyChainMcpServer < FastMcp::Server
  def initialize
    super(name: "Ecosyste.ms MCP Server", version: "1.0.0")
    @client = EcosystemsClient.new
    @service = PackageInfoService.new
    
    setup_tools
  end

  private

  def setup_tools
    register_tool(
      name: "get_package_name",
      description: "Extract package name from ecosyste.ms API response",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      response = @client.lookup_by_purl(params[:purl])
      return { error: "Package not found" } unless response
      
      { name: @service.extract_name(response) }
    end

    register_tool(
      name: "get_authors",
      description: "Extract author/maintainer information from package data",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      response = @client.lookup_by_purl(params[:purl])
      return { error: "Package not found" } unless response
      
      { author: @service.extract_author(response) }
    end

    register_tool(
      name: "get_version",
      description: "Get the latest version of a package",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      response = @client.lookup_by_purl(params[:purl])
      return { error: "Package not found" } unless response
      
      { version: @service.extract_version(response) }
    end

    register_tool(
      name: "get_description",
      description: "Get package description",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      response = @client.lookup_by_purl(params[:purl])
      return { error: "Package not found" } unless response
      
      { description: @service.extract_description(response) }
    end

    register_tool(
      name: "get_license",
      description: "Get package license information",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      response = @client.lookup_by_purl(params[:purl])
      return { error: "Package not found" } unless response
      
      license = @service.extract_license(response)
      # Truncate very long license texts
      license = license.length > 200 ? "#{license[0, 197]}..." : license if license
      
      { license: license }
    end

    register_tool(
      name: "get_repository",
      description: "Get package repository URL",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      response = @client.lookup_by_purl(params[:purl])
      return { error: "Package not found" } unless response
      
      { repository: @service.extract_repository(response) }
    end

    register_tool(
      name: "get_purl",
      description: "Generate standardized Package URL from package data",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      response = @client.lookup_by_purl(params[:purl])
      return { error: "Package not found" } unless response
      
      { purl: @service.generate_purl(response) }
    end

    register_tool(
      name: "analyze_package",
      description: "Get complete package analysis including all available metadata",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      response = @client.lookup_by_purl(params[:purl])
      return { error: "Package not found" } unless response
      
      license = @service.extract_license(response)
      license = license.length > 200 ? "#{license[0, 197]}..." : license if license
      
      {
        name: @service.extract_name(response),
        author: @service.extract_author(response),
        version: @service.extract_version(response),
        description: @service.extract_description(response),
        license: license,
        repository: @service.extract_repository(response),
        purl: @service.generate_purl(response),
        ecosystem: response["ecosystem"]
      }
    end

    register_tool(
      name: "lookup_vulnerabilities",
      description: "Check for known vulnerabilities in a package",
      parameters: {
        purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
      }
    ) do |params|
      # Parse the purl to get registry and name
      purl_obj = Purl::PackageURL.parse(params[:purl])
      registry = case purl_obj.type
                 when "pypi" then "pypi"
                 when "npm" then "npmjs"
                 when "cargo" then "cargo"
                 when "gem" then "rubygems"
                 else purl_obj.type
                 end
      
      vulnerabilities = @client.vulnerabilities(registry, purl_obj.name)
      
      if vulnerabilities && vulnerabilities.any?
        {
          has_vulnerabilities: true,
          count: vulnerabilities.length,
          vulnerabilities: vulnerabilities.map do |vuln|
            {
              id: vuln["advisory_identifier"],
              summary: vuln["summary"],
              severity: vuln["severity"]
            }
          end
        }
      else
        { has_vulnerabilities: false, count: 0 }
      end
    end
  end
end