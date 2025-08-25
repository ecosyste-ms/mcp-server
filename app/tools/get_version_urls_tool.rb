class GetVersionUrlsTool < BaseTool
  def self.description
    "Get ecosyste.ms URLs for specific version analysis"
  end

  def self.category
    "Version"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL with version (e.g. pkg:pypi/numpy@1.24.0)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["purl", "context"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    parts = purl_string.split('@')
    return { error: "Version required in PURL" } unless parts.length == 2
    
    package_purl, version = parts
    purl_parts = package_purl.split('/')
    return { error: "Invalid PURL format" } unless purl_parts.length >= 2
    
    ecosystem = purl_parts[0].split(':')[1]
    name = purl_parts[1]
    
    base_url = "https://packages.ecosyste.ms"
    
    {
      version_url: "#{base_url}/#{ecosystem}/#{name}/versions/#{version}",
      dependencies_url: "#{base_url}/#{ecosystem}/#{name}/versions/#{version}/dependencies",
      download_url: "#{base_url}/#{ecosystem}/#{name}/versions/#{version}/download"
    }
  end
end