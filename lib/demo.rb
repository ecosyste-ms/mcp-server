#!/usr/bin/env ruby

require_relative '../config/environment'

class PackageAnalysisDemo
  def initialize
    @client = EcosystemsClient.new
    @service = PackageInfoService.new
  end

  def analyze_package_by_purl(purl)
    puts "Analyzing package: #{purl}"
    puts "-" * 50
    
    response = @client.lookup_by_purl(purl)
    
    if response.nil?
      puts "Package not found!"
      return
    end
    
    puts "Name: #{@service.extract_name(response) || 'N/A'}"
    puts "Description: #{@service.extract_description(response) || 'N/A'}"
    puts "Version: #{@service.extract_version(response) || 'N/A'}"
    license = @service.extract_license(response) || 'N/A'
    license = license.length > 100 ? "#{license[0, 97]}..." : license
    puts "License: #{license}"
    puts "Repository: #{@service.extract_repository(response) || 'N/A'}"
    puts "Author: #{@service.extract_author(response) || 'N/A'}"
    puts "Generated PURL: #{@service.generate_purl(response) || 'N/A'}"
    puts
  end

  def run_demo
    puts "Package Analysis Demo"
    puts "=" * 50
    puts
    
    # Demo with different ecosystems
    packages = [
      "pkg:cargo/rand",
      "pkg:pypi/numpy", 
      "pkg:npm/@types/node",
      "pkg:gem/rails"
    ]
    
    packages.each do |purl|
      analyze_package_by_purl(purl)
    end
  end
end

# Run the demo if this file is executed directly
if __FILE__ == $0
  demo = PackageAnalysisDemo.new
  demo.run_demo
end