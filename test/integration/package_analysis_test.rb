require 'test_helper'

class PackageAnalysisTest < ActiveSupport::TestCase
  def setup
    @client = EcosystemsClient.new
    @service = PackageInfoService.new
  end

  test "should successfully analyze a real package via purl" do
    skip "Integration test - requires network" unless ENV['RUN_INTEGRATION_TESTS']
    
    purl = "pkg:cargo/rand"
    response = @client.lookup_by_purl(purl)
    
    assert_not_nil response
    
    # Test extracting basic info
    name = @service.extract_name(response)
    assert_equal "rand", name
    
    description = @service.extract_description(response)
    assert_not_nil description
    assert description.include?("Random")
    
    license = @service.extract_license(response)
    assert_not_nil license
    
    repository = @service.extract_repository(response)
    assert_not_nil repository
    assert repository.include?("github.com")
    
    generated_purl = @service.generate_purl(response)
    assert generated_purl.start_with?("pkg:cargo/rand")
  end

  test "should analyze numpy package via purl" do
    skip "Integration test - requires network" unless ENV['RUN_INTEGRATION_TESTS']
    
    purl = "pkg:pypi/numpy"
    response = @client.lookup_by_purl(purl)
    
    assert_not_nil response
    
    name = @service.extract_name(response)
    assert_equal "numpy", name
    
    description = @service.extract_description(response)
    assert_not_nil description
    
    license = @service.extract_license(response)
    assert_not_nil license
    
    repository = @service.extract_repository(response)
    assert repository.include?("github.com/numpy/numpy")
  end

  test "should handle non-existent package gracefully" do
    skip "Integration test - requires network" unless ENV['RUN_INTEGRATION_TESTS']
    
    response = @client.lookup_by_package("pypi", "this-package-definitely-does-not-exist-12345")
    
    assert_nil response
  end
end