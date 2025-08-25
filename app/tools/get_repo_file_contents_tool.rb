require 'cgi'

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

    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup

    # Try to use file contents URL if available, or construct it from files URL
    files_base_url = repo_lookup["files_url"]
    if files_base_url
      # Construct file content URL by appending the file path
      file_contents_url = "#{files_base_url}/#{file_path}"
      content = @client.fetch_external_api(file_contents_url)
    else
      # Fall back to the original pattern if no direct URL is available
      host = repo_lookup["host"]["name"]
      full_name = repo_lookup["full_name"]
      owner, repo = full_name.split("/", 2) if full_name
      
      return { error: "Invalid repository format" } unless owner && repo
      
      # Construct the archives API URL manually
      encoded_owner = CGI.escape(owner)
      encoded_repo = CGI.escape(repo)
      file_contents_url = "https://archives.ecosyste.ms/api/v1/repositories/#{host}/#{encoded_owner}/#{encoded_repo}/files/#{file_path}"
      content = @client.fetch_external_api(file_contents_url)
    end
    
    {
      file_path: file_path,
      content: content,
      exists: !content.nil?
    }
  end
end