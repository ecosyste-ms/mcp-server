class GetRepoFileContentsTool < BaseTool
  def self.description
    "Get contents of a specific file from a repository using archives API"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy)" },
        file_path: { type: "string", description: "Path to file within repository (e.g. LICENSE, README.md)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["repo_url", "file_path", "context"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    file_path = arguments[:file_path] || arguments["file_path"]
    return { error: "Repository URL required" } unless repo_url
    return { error: "File path required" } unless file_path

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      content = @client.repository_file_contents("GitHub", owner, repo, file_path)
      
      {
        file_path: file_path,
        content: content,
        exists: !content.nil?
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end