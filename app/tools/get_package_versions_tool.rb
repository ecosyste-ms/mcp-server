class GetPackageVersionsTool < BaseTool
  def self.description
    "Get complete list of all versions for a package"
  end

  def self.category
    "Version"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g. pkg:cargo/rand)" },
        page: { type: "number", description: "Page number (default: 1)" },
        per_page: { type: "number", description: "Items per page (default: 30, max: 100)" }
      },
      required: ["purl"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    page = arguments[:page] || arguments["page"] || 1
    per_page = arguments[:per_page] || arguments["per_page"] || 30
    
    versions = @client.package_versions(purl_string, page: page, per_page: per_page)
    
    if versions && versions.any?
      {
        versions: versions.map do |version|
          {
            number: version["number"],
            published_at: version["published_at"],
            original_license: version["original_license"],
            repository_sources: version["repository_sources"]
          }
        end,
        pagination: {
          page: page,
          per_page: per_page,
          total_count: versions.first&.dig("total_count")
        }
      }
    else
      { versions: [], pagination: { page: page, per_page: per_page, total_count: 0 } }
    end
  end
end