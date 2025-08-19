require 'test_helper'

class EcosystemsClientTest < ActiveSupport::TestCase
  def setup
    @client = EcosystemsClient.new
  end

  test "should construct correct purl lookup URL" do
    purl = "pkg:cargo/rand"
    expected_url = "https://packages.ecosyste.ms/api/v1/packages/lookup?purl=#{CGI.escape(purl)}"
    
    assert_equal expected_url, @client.purl_lookup_url(purl)
  end

  test "should construct correct package lookup URL" do
    registry = "pypi"
    name = "numpy"
    expected_url = "https://packages.ecosyste.ms/api/v1/registries/pypi/packages/numpy"
    
    assert_equal expected_url, @client.package_lookup_url(registry, name)
  end

  test "should handle URL encoding for package names with special characters" do
    registry = "npm"
    name = "@types/node"
    expected_url = "https://packages.ecosyste.ms/api/v1/registries/npm/packages/%40types%2Fnode"
    
    assert_equal expected_url, @client.package_lookup_url(registry, name)
  end

  test "should return base endpoints" do
    assert_equal "https://packages.ecosyste.ms/api/v1", @client.packages_base_url
    assert_equal "https://repos.ecosyste.ms/api/v1", @client.repos_base_url
  end

  test "should construct correct vulnerabilities URL" do
    ecosystem = "pypi"
    name = "numpy"
    expected_url = "https://advisories.ecosyste.ms/api/v1/advisories?ecosystem=pypi&package_name=numpy"
    
    # Mock the make_request method to capture the URL
    url_captured = nil
    @client.define_singleton_method(:make_request) do |url|
      url_captured = url
      []
    end
    
    @client.vulnerabilities(ecosystem, name)
    assert_equal expected_url, url_captured
  end

end