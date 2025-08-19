require 'purl'

class PackageInfoService
  def extract_name(response)
    response["name"]
  end

  def extract_author(response)
    authors = []
    
    # Check maintainers field
    maintainers = response["maintainers"]
    if maintainers&.any?
      maintainer_names = maintainers.map do |maintainer|
        name = maintainer["name"]
        email = maintainer["email"]
        login = maintainer["login"]
        
        if name && email
          "#{name} <#{email}>"
        elsif name
          name
        elsif login
          login
        else
          email
        end
      end.compact
      
      authors.concat(maintainer_names)
    end
    
    # Check repository owner field
    owner = response.dig("owner", "name") || response.dig("owner", "login")
    if owner && !authors.include?(owner)
      authors << owner
    end
    
    # Return formatted authors or fallback to "Unknown"
    if authors.any?
      authors.join(", ")
    else
      "Unknown"
    end
  end

  def extract_version(response)
    response.dig("latest_stable_release", "number")
  end

  def extract_description(response)
    description = response["description"]
    return nil unless description

    if description.length > 150
      "#{description[0, 147]}..."
    else
      description
    end
  end

  def extract_license(response)
    response["licenses"]
  end

  def extract_repository(response)
    repo_url = response["repository_url"]
    return nil unless repo_url

    # Normalize GitHub/GitLab URLs
    repo_url = repo_url.gsub(/\.git$/, "")
    repo_url = repo_url.gsub(/^https?:\/\//, "")
    repo_url
  end

  def generate_purl(response)
    name = response["name"]
    ecosystem = response["ecosystem"]
    version = response.dig("latest_stable_release", "number")
    
    return nil unless name && ecosystem

    # Map ecosystem names to purl types
    purl_type = case ecosystem.downcase
                when "pypi" then "pypi"
                when "npm", "npmjs" then "npm"
                when "cargo" then "cargo"
                when "rubygems" then "gem"
                when "maven" then "maven"
                when "nuget" then "nuget"
                else ecosystem.downcase
                end

    # Use the purl gem to properly construct the PURL
    purl_obj = Purl::PackageURL.new(
      type: purl_type,
      name: name,
      version: version
    )
    
    purl_obj.to_s
  end
end