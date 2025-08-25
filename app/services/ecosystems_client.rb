require 'net/http'
require 'json'
require 'cgi'
require 'digest'

class EcosystemsClient
  PACKAGES_BASE_URL = 'https://packages.ecosyste.ms/api/v1'
  REPOS_BASE_URL = 'https://repos.ecosyste.ms/api/v1'
  ISSUES_BASE_URL = 'https://issues.ecosyste.ms/api/v1'
  COMMITS_BASE_URL = 'https://commits.ecosyste.ms/api/v1'
  
  # Cache TTL settings - 24 hours for all API responses
  CACHE_TTL = 24.hours

  def packages_base_url
    PACKAGES_BASE_URL
  end

  def repos_base_url
    REPOS_BASE_URL
  end

  def purl_lookup_url(purl)
    "#{PACKAGES_BASE_URL}/packages/lookup?purl=#{CGI.escape(purl)}"
  end

  def package_lookup_url(registry, name)
    encoded_name = CGI.escape(name)
    "#{PACKAGES_BASE_URL}/registries/#{registry}/packages/#{encoded_name}"
  end

  def lookup_by_purl(purl)
    url = purl_lookup_url(purl)
    response = make_request(url)
    
    # PURL lookup returns an array, return first result or nil if empty
    if response.is_a?(Array) && response.any?
      response.first
    else
      nil
    end
  end

  def lookup_by_package(registry, name)
    url = package_lookup_url(registry, name)
    make_request(url)
  end

  def lookup_package_version(registry, name, version)
    encoded_name = CGI.escape(name)
    url = "#{PACKAGES_BASE_URL}/registries/#{registry}/packages/#{encoded_name}/versions/#{version}"
    make_request(url)
  end

  def version_info(package_purl, version)
    # First lookup the package to get registry and name
    package_info = lookup_by_purl(package_purl)
    return nil unless package_info
    
    registry = package_info["registry"]
    name = package_info["name"]
    
    lookup_package_version(registry, name, version)
  end

  def vulnerabilities(ecosystem, package_name)
    encoded_name = CGI.escape(package_name)
    url = "https://advisories.ecosyste.ms/api/v1/advisories?ecosystem=#{ecosystem}&package_name=#{encoded_name}"
    make_request(url)
  end

  def vulnerabilities_by_purl(purl)
    encoded_purl = CGI.escape(purl)
    url = "https://advisories.ecosyste.ms/api/v1/advisories/lookup?purl=#{encoded_purl}"
    make_request(url)
  end

  def repository_info(host, owner, repo)
    url = "#{REPOS_BASE_URL}/hosts/#{host}/repositories/#{owner}/#{repo}"
    make_request(url)
  end

  def repository_issues(host, owner, repo)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    url = "#{ISSUES_BASE_URL}/hosts/#{host}/repositories/#{encoded_owner}%2F#{encoded_repo}"
    make_request(url)
  end

  def repository_commits(host, owner, repo)
    url = "#{COMMITS_BASE_URL}/hosts/#{host}/repositories/#{owner}/#{repo}"
    make_request(url)
  end

  def repository_scorecard(host, owner, repo)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    url = "#{REPOS_BASE_URL}/hosts/#{host}/repositories/#{encoded_owner}%2F#{encoded_repo}/scorecard"
    make_request(url)
  end

  def repository_readme(host, owner, repo)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    url = "https://archives.ecosyste.ms/api/v1/repositories/#{host}/#{encoded_owner}/#{encoded_repo}/readme"
    make_request(url)
  end

  def repository_files(host, owner, repo)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    url = "https://archives.ecosyste.ms/api/v1/repositories/#{host}/#{encoded_owner}/#{encoded_repo}/files"
    make_request(url)
  end

  def repository_tags(host, owner, repo, page: 1, per_page: 30)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    url = "#{REPOS_BASE_URL}/hosts/#{host}/repositories/#{encoded_owner}%2F#{encoded_repo}/tags?page=#{page}&per_page=#{per_page}"
    make_request(url)
  end

  def repository_activity(repo_url)
    # This method seems to take a full repo URL rather than host/owner/repo
    # Need to implement based on the actual API endpoint
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return nil if parts.length < 2
      owner, repo = parts[0], parts[1]
      encoded_owner = CGI.escape(owner)
      encoded_repo = CGI.escape(repo)
      url = "#{REPOS_BASE_URL}/hosts/GitHub/repositories/#{encoded_owner}%2F#{encoded_repo}"
      repo_data = make_request(url)
      # Return activity-related fields from the repo data
      return repo_data if repo_data
    end
    nil
  end

  def repository_changelog(host, owner, repo, version = nil)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    base_url = "https://archives.ecosyste.ms/api/v1/repositories/#{host}/#{encoded_owner}/#{encoded_repo}/changelog"
    url = version ? "#{base_url}?version=#{version}" : base_url
    make_request(url)
  end

  def repository_committers(host, owner, repo)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    url = "#{COMMITS_BASE_URL}/hosts/#{host}/repositories/#{encoded_owner}%2F#{encoded_repo}/committers"
    make_request(url)
  end

  def repository_past_year_activity(host, owner, repo)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    url = "#{ISSUES_BASE_URL}/hosts/#{host}/repositories/#{encoded_owner}%2F#{encoded_repo}/activity"
    make_request(url)
  end

  def package_versions(purl, page: 1, per_page: 30)
    encoded_purl = CGI.escape(purl)
    url = "#{PACKAGES_BASE_URL}/packages/lookup?purl=#{encoded_purl}/versions?page=#{page}&per_page=#{per_page}"
    # This might need adjustment based on the actual API
    package_info = lookup_by_purl(purl)
    return [] unless package_info
    
    registry = package_info["registry"]
    name = package_info["name"]
    encoded_name = CGI.escape(name)
    url = "#{PACKAGES_BASE_URL}/registries/#{registry}/packages/#{encoded_name}/versions?page=#{page}&per_page=#{per_page}"
    make_request(url)
  end

  def dependent_packages(purl, page: 1)
    encoded_purl = CGI.escape(purl)
    url = "#{PACKAGES_BASE_URL}/packages/lookup?purl=#{encoded_purl}/dependents?page=#{page}"
    # This might need adjustment based on the actual API
    package_info = lookup_by_purl(purl)
    return [] unless package_info
    
    registry = package_info["registry"]
    name = package_info["name"]
    encoded_name = CGI.escape(name)
    url = "#{PACKAGES_BASE_URL}/registries/#{registry}/packages/#{encoded_name}/dependents?page=#{page}"
    make_request(url)
  end

  def related_packages(purl, page: 1)
    encoded_purl = CGI.escape(purl)
    url = "#{PACKAGES_BASE_URL}/packages/lookup?purl=#{encoded_purl}/related?page=#{page}"
    # This might need adjustment based on the actual API
    package_info = lookup_by_purl(purl)
    return [] unless package_info
    
    registry = package_info["registry"]
    name = package_info["name"]
    encoded_name = CGI.escape(name)
    url = "#{PACKAGES_BASE_URL}/registries/#{registry}/packages/#{encoded_name}/related?page=#{page}"
    make_request(url)
  end

  def package_maintainers(purl)
    package_info = lookup_by_purl(purl)
    return [] unless package_info
    
    registry = package_info["registry"]
    name = package_info["name"]
    encoded_name = CGI.escape(name)
    url = "#{PACKAGES_BASE_URL}/registries/#{registry}/packages/#{encoded_name}/maintainers"
    make_request(url)
  end

  def version_dependencies(package_purl, version)
    package_info = lookup_by_purl(package_purl)
    return [] unless package_info
    
    registry = package_info["registry"]
    name = package_info["name"]
    encoded_name = CGI.escape(name)
    url = "#{PACKAGES_BASE_URL}/registries/#{registry}/packages/#{encoded_name}/versions/#{version}/dependencies"
    make_request(url)
  end

  def package_version_numbers(purl)
    package_info = lookup_by_purl(purl)
    return [] unless package_info
    
    registry = package_info["registry"]
    name = package_info["name"]
    encoded_name = CGI.escape(name)
    url = "#{PACKAGES_BASE_URL}/registries/#{registry}/packages/#{encoded_name}/versions"
    versions_response = make_request(url)
    
    # Extract just the version numbers
    if versions_response && versions_response.is_a?(Array)
      versions_response.map { |v| v["number"] }.compact
    else
      []
    end
  end

  def package_dependencies(purl)
    package_info = lookup_by_purl(purl)
    return [] unless package_info
    
    # Get the latest version dependencies
    latest_version = package_info["latest_release_number"]
    return [] unless latest_version
    
    version_dependencies(purl, latest_version)
  end

  def repository_manifests(host, owner, repo)
    encoded_owner = CGI.escape(owner)
    encoded_repo = CGI.escape(repo)
    url = "#{REPOS_BASE_URL}/hosts/#{host}/repositories/#{encoded_owner}%2F#{encoded_repo}/manifests"
    make_request(url)
  end

  # Generic request method for archives API and other external endpoints
  def fetch_external_api(url)
    make_request(url)
  end

  def packages_by_repository_url(repository_url)
    encoded_url = CGI.escape(repository_url)
    url = "#{PACKAGES_BASE_URL}/packages/lookup?repository_url=#{encoded_url}"
    make_request(url)
  end

  def maintainer_packages(registry, maintainer_name)
    encoded_maintainer = CGI.escape(maintainer_name)
    url = "#{PACKAGES_BASE_URL}/registries/#{registry}/maintainers/#{encoded_maintainer}/packages"
    make_request(url)
  end

  def registry_list
    url = "#{PACKAGES_BASE_URL}/registries"
    make_request(url)
  end

  private

  def make_request(url, max_retries: 3)
    cache_key = "ecosystems_api:#{Digest::MD5.hexdigest(url)}"
    
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      Rails.logger.info "Making API request (cache miss): #{url}"
      
      retries = 0
      begin
        uri = URI(url)
        
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 30, read_timeout: 30) do |http|
          request = Net::HTTP::Get.new(uri)
          request['User-Agent'] = 'mcp.ecosyste.ms'
          
          response = http.request(request)
          
          case response.code
          when '200'
            JSON.parse(response.body)
          when '404'
            nil
          when '500', '502', '503', '504', '429' # Server errors and rate limiting
            if retries < max_retries
              retries += 1
              wait_time = 2 ** retries # Exponential backoff: 2, 4, 8 seconds
              Rails.logger.warn "API request failed with #{response.code}, retrying in #{wait_time}s (attempt #{retries}/#{max_retries}): #{url}"
              sleep(wait_time)
              redo
            else
              Rails.logger.error "API request failed after #{max_retries} retries: #{response.code} #{response.message} for #{url}"
              nil
            end
          else
            Rails.logger.error "API request failed: #{response.code} #{response.message} for #{url}"
            nil
          end
        end
      rescue Net::TimeoutError, Net::OpenTimeout, Errno::ECONNRESET => e
        if retries < max_retries
          retries += 1
          wait_time = 2 ** retries
          Rails.logger.warn "Network error, retrying in #{wait_time}s (attempt #{retries}/#{max_retries}): #{e.message} for #{url}"
          sleep(wait_time)
          retry
        else
          Rails.logger.error "Network error after #{max_retries} retries: #{e.message} for #{url}"
          nil
        end
      end
    end
  rescue StandardError => e
    Rails.logger.error "API request error: #{e.message} for #{url}"
    nil
  end
end