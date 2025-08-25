class BaseTool
  def initialize(client = nil)
    @client = client || EcosystemsClient.new
  end

  def self.tool_name
    name.underscore.gsub('_tool', '')
  end

  def self.description
    raise NotImplementedError, "Must implement description"
  end

  def self.category
    "Uncategorized"
  end

  def self.input_schema
    raise NotImplementedError, "Must implement input_schema"
  end

  def call(arguments)
    raise NotImplementedError, "Must implement call method"
  end

  def self.to_mcp_tool
    {
      name: tool_name,
      description: description,
      inputSchema: input_schema,
      category: category
    }
  end

  protected

  def extract_purl(args)
    args[:purl] || args["purl"]
  end

  def extract_repo_url(args)
    args[:repo_url] || args["repo_url"]
  end

  def extract_version_from_purl(purl)
    # Extract version from PURL format: pkg:type/namespace/name@version
    return nil unless purl&.include?('@')
    purl.split('@').last
  end

  def version_affected_by_vulnerability?(vulnerability, target_version, ecosystem)
    return true unless target_version # If no version specified, show all vulnerabilities
    
    # Find the package entry for the specified ecosystem
    package_entry = vulnerability["packages"]&.find do |pkg|
      pkg["ecosystem"]&.downcase == ecosystem.downcase
    end
    
    return true unless package_entry # If no ecosystem match, include the vulnerability
    
    # Check if the target version is in the affected versions list
    affected_versions = package_entry["affected_versions"]
    if affected_versions&.is_a?(Array)
      return affected_versions.include?(target_version)
    end
    
    # If no specific affected versions list, assume it affects the version
    # (This is a fallback - in practice, most vulnerabilities should have affected_versions)
    true
  end
end