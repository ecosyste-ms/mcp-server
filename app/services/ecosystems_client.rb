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

  def vulnerabilities(ecosystem, package_name)
    encoded_name = CGI.escape(package_name)
    url = "https://advisories.ecosyste.ms/api/v1/advisories?ecosystem=#{ecosystem}&package_name=#{encoded_name}"
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

  private

  def make_request(url)
    cache_key = "ecosystems_api:#{Digest::MD5.hexdigest(url)}"
    
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      Rails.logger.info "Making API request (cache miss): #{url}"
      
      uri = URI(url)
      
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri)
        request['User-Agent'] = 'MCP-Supply-Chain-Analyzer/1.0'
        
        response = http.request(request)
        
        case response.code
        when '200'
          JSON.parse(response.body)
        when '404'
          nil
        else
          Rails.logger.error "API request failed: #{response.code} #{response.message} for #{url}"
          nil
        end
      end
    end
  rescue StandardError => e
    Rails.logger.error "API request error: #{e.message} for #{url}"
    nil
  end
end