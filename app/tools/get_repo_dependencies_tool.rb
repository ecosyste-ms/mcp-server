class GetRepoDependenciesTool < BaseTool
  def self.description
    "Get dependencies for a repository from manifest files"
  end

  def self.category
    "Dependencies"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/octobox/octobox)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["repo_url", "context"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup

    # Use the direct manifests API URL from the lookup response
    manifests_api_url = repo_lookup["manifests_url"]
    return { error: "Manifests API URL not available" } unless manifests_api_url

    # Make API call using the direct URL
    dependencies = @client.fetch_external_api(manifests_api_url)
    
    if dependencies && dependencies.any?
      {
        dependencies: dependencies.map do |dep|
          {
            name: dep["name"],
            requirement: dep["requirement"],
            kind: dep["kind"],
            ecosystem: dep["ecosystem"],
            optional: dep["optional"]
          }
        end
      }
    else
      { dependencies: [] }
    end
  end
end