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

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      dependencies = @client.repository_dependencies("GitHub", owner, repo)
      
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
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end