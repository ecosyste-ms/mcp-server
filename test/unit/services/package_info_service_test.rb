require 'test_helper'

class PackageInfoServiceTest < ActiveSupport::TestCase
  def setup
    @service = PackageInfoService.new
  end

  test "should extract package name from response" do
    mock_response = {
      "name" => "numpy",
      "ecosystem" => "Pypi"
    }
    
    result = @service.extract_name(mock_response)
    assert_equal "numpy", result
  end

  test "should handle missing name field" do
    mock_response = {}
    
    result = @service.extract_name(mock_response)
    assert_nil result
  end

  test "should extract author from response" do
    mock_response = {
      "maintainers" => [
        {
          "name" => "NumPy Developers",
          "email" => "numpy-discussion@python.org"
        }
      ]
    }
    
    result = @service.extract_author(mock_response)
    assert_equal "NumPy Developers <numpy-discussion@python.org>", result
  end

  test "should handle multiple maintainers" do
    mock_response = {
      "maintainers" => [
        {"name" => "Dev One", "email" => "dev1@example.com"},
        {"name" => "Dev Two", "email" => "dev2@example.com"}
      ]
    }
    
    result = @service.extract_author(mock_response)
    assert_equal "Dev One <dev1@example.com>, Dev Two <dev2@example.com>", result
  end

  test "should extract latest version" do
    mock_response = {
      "latest_release_published_at" => "2024-01-15T10:30:00Z",
      "latest_stable_release" => {
        "number" => "1.26.4"
      }
    }
    
    result = @service.extract_version(mock_response)
    assert_equal "1.26.4", result
  end

  test "should extract description" do
    mock_response = {
      "description" => "Fundamental package for array computing in Python."
    }
    
    result = @service.extract_description(mock_response)
    assert_equal "Fundamental package for array computing in Python.", result
  end

  test "should truncate long descriptions" do
    long_description = "A" * 200
    mock_response = {
      "description" => long_description
    }
    
    result = @service.extract_description(mock_response)
    assert result.length <= 150
    assert result.end_with?("...")
  end

  test "should extract license" do
    mock_response = {
      "licenses" => "BSD-3-Clause"
    }
    
    result = @service.extract_license(mock_response)
    assert_equal "BSD-3-Clause", result
  end

  test "should extract repository URL" do
    mock_response = {
      "repository_url" => "https://github.com/numpy/numpy"
    }
    
    result = @service.extract_repository(mock_response)
    assert_equal "github.com/numpy/numpy", result
  end

  test "should normalize repository URL" do
    mock_response = {
      "repository_url" => "https://github.com/numpy/numpy.git"
    }
    
    result = @service.extract_repository(mock_response)
    assert_equal "github.com/numpy/numpy", result
  end

  test "should generate purl from package data" do
    mock_response = {
      "name" => "rand",
      "ecosystem" => "Cargo",
      "latest_stable_release" => {
        "number" => "0.8.5"
      }
    }
    
    result = @service.generate_purl(mock_response)
    assert_equal "pkg:cargo/rand@0.8.5", result
  end

  test "should generate purl for scoped npm packages" do
    mock_response = {
      "name" => "@types/node",
      "ecosystem" => "npm",
      "latest_stable_release" => {
        "number" => "20.0.0"
      }
    }
    
    result = @service.generate_purl(mock_response)
    assert_equal "pkg:npm/%40types%2Fnode@20.0.0", result
  end
end