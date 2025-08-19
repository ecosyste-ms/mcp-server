class GetRepoReleasesTool < BaseTool
  def self.description
    "Get repository releases using ecosyste.ms repos API"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" },
        page: { type: "number", description: "Page number (default: 1)" },
        per_page: { type: "number", description: "Items per page (default: 30)" }
      },
      required: ["repo_url"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    page = arguments[:page] || arguments["page"] || 1
    per_page = arguments[:per_page] || arguments["per_page"] || 30

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      releases = @client.repository_releases("GitHub", owner, repo, page: page, per_page: per_page)
      
      if releases && releases.any?
        {
          releases: releases.map do |release|
            {
              tag_name: release["tag_name"],
              name: release["name"],
              body: release["body"],
              draft: release["draft"],
              prerelease: release["prerelease"],
              published_at: release["published_at"]
            }
          end,
          pagination: { page: page, per_page: per_page }
        }
      else
        { releases: [], pagination: { page: page, per_page: per_page } }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end