# Ecosyste.ms MCP Server

A Model Control Protocol (MCP) server providing field-level access to ecosyste.ms package ecosystem data. Connect this server to Claude Desktop, Claude Code, ChatGPT, or any MCP-compatible LLM to build package analysis workflows using raw data.

## Available Tools

### Package Metadata
- `get_package_basic_info` - Basic package info (id, name, ecosystem, description, homepage, licenses)
- `get_package_dates` - Creation and update dates
- `get_package_repository_info` - Repository URL and social metrics (stars, forks)
- `get_package_versions_info` - Version count and latest release info
- `get_package_keywords` - Keywords and categories
- `get_package_urls` - Ecosyste.ms URLs and related links
- `get_package_metrics` - Downloads, dependents, stars, forks, rankings, maintainers
- `get_funding_links` - Funding links
- `get_latest_version` - Latest version information

### Version-Specific
- `get_version_info` - Specific version metadata (published_at, downloads, author, checksum, size)
- `get_version_dependencies` - Dependencies for a specific version (requires PURL with version)
- `get_package_dependencies` - Dependencies for latest version
- `get_package_versions` - Complete version list with pagination
- `get_package_version_numbers` - Simple version number list (lightweight)
- `get_related_packages` - Related packages with pagination
- `get_dependent_packages` - Packages that depend on this one
- `get_package_maintainers` - Maintainer list with details
- `get_maintainer_packages` - Packages by a specific maintainer
- `get_version_urls` - URLs for specific version analysis

### Repository Analysis
All repository tools accept either direct URLs (e.g. `github.com/numpy/numpy`) or PURLs (e.g. `pkg:pypi/numpy`). When given a PURL, the tool resolves the package's repository URL automatically.

- `get_repo_basic_info` - Basic info (id, full_name, owner, description, archived, fork)
- `get_repo_activity` - Activity metrics (pushed_at, size, last_synced_at)
- `get_repo_community` - Community metrics (stars, forks, subscribers, open_issues)
- `get_repo_metadata` - Metadata (topics, language, license, default_branch)
- `get_repo_dependencies` - Dependencies from manifest files (Gemfile, package.json, etc.)
- `get_repo_metafiles` - Interesting metadata files (LICENSE, README, etc.)
- `get_repo_files` - Complete file list via archives API
- `get_repo_file_contents` - Specific file contents via archives API
- `get_repo_readme` - README content via archives API
- `get_repo_changelog` - Changelog with parsed version entries
- `get_repo_repomix` - AI-friendly concatenated repository contents
- `get_repo_tags` - Tags with pagination
- `get_repo_releases` - Releases with pagination
- `get_repo_sbom` - Software Bill of Materials
- `get_repo_owner` - Owner information
- `get_repo_scorecard` - Security scorecard
- `get_repo_urls` - Ecosyste.ms URLs across all platforms
- `get_repo_package_names` - Package names associated with a repository

### Issue Tracking
- `get_issue_counts` - Issue and PR counts (total, closed)
- `get_issue_timing` - Average time to close issues and PRs
- `get_maintainer_info` - Maintainer lists (all-time and active)
- `get_contributor_counts` - Contributor counts for PRs and issues
- `get_past_year_activity` - Past year issue and PR activity

### Commit Activity
- `get_commit_overview` - Repository commit overview
- `get_committer_list` - Complete list of committers with counts
- `get_top_committers` - Top N committers by count

### Vulnerabilities
- `get_vulnerability_list` - Detailed vulnerability list with CVE details
- `get_vulnerability_counts_by_severity` - Counts grouped by severity
- `get_latest_vulnerability_date` - Date of most recent vulnerability

### Registry
- `get_registry_list` - All available package registries

## Connecting to Your LLM

### Claude Desktop
Add to your `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "ecosystems": {
      "command": "curl",
      "args": [
        "-X", "POST",
        "http://localhost:3000/mcp",
        "-H", "Content-Type: application/json",
        "-d", "@-"
      ]
    }
  }
}
```

### Claude Code
Start the server first with `rails server`, then add it:
```bash
claude mcp add ecosystems http://localhost:3000/mcp -t http
```

Or add manually to your Claude Code settings:
```json
{
  "mcp.servers": {
    "ecosystems": {
      "url": "http://localhost:3000/mcp"
    }
  }
}
```

### ChatGPT (Custom GPT/Actions)
Create a GPT Action with this OpenAPI spec:
```yaml
openapi: 3.0.0
info:
  title: Ecosystems MCP Server
  version: 1.0.0
servers:
  - url: http://localhost:3000
paths:
  /mcp:
    post:
      operationId: callMcpTool
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                jsonrpc:
                  type: string
                  default: "2.0"
                method:
                  type: string
                  enum: ["tools/list", "tools/call"]
                params:
                  type: object
      responses:
        '200':
          description: MCP response
```

### Generic MCP Client
Connect to `http://localhost:3000/mcp` using JSON-RPC 2.0. Methods: `tools/list`, `tools/call`.

## Quick Start

```bash
git clone https://github.com/ecosyste-ms/mcp-server
cd mcp-server
bundle install
rails server
```

Test it:
```bash
# Health check
curl http://localhost:3000/mcp/health

# List available tools
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}'

# Analyze a package
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": {"name": "assess_importance", "arguments": {"purl": "pkg:pypi/numpy"}}}'
```

## Example Prompts

Once connected, try these:

**Analyze numpy's dependencies and vulnerabilities**
```
Use the MCP tools to:
1. Get basic info for pkg:pypi/numpy
2. Get its latest dependencies
3. Check vulnerability counts by severity
4. Show the top 5 committers for the numpy/numpy repository
```

**Compare packages across ecosystems**
```
Compare package metadata between:
- pkg:pypi/requests (Python)
- pkg:npm/axios (Node.js)
- pkg:cargo/reqwest (Rust)

Use tools to get basic info, repository metrics, and latest versions for each.
```

**Analyze repository activity**
```
For github.com/microsoft/vscode:
1. Get repository community metrics
2. Get dependencies from manifest files
3. Get issue counts and timing
4. Show maintainer information
```

**Dependency tree analysis**
```
Get dependencies for pkg:cargo/tokio and then analyze the dependencies
of its top 3 normal (non-dev) dependencies using the version-specific tools.
```

**Explore repository files**
```
For github.com/numpy/numpy:
1. Get metadata files using get_repo_metafiles
2. Get complete file list using get_repo_files
3. Get README content using get_repo_readme
4. Get changelog with parsed versions using get_repo_changelog
5. Get AI-friendly concatenated codebase using get_repo_repomix
6. Get contents of specific files using get_repo_file_contents
```

## Architecture

The server consists of three main components:

`SimpleMcpServer` handles the JSON-RPC 2.0 protocol. `EcosystemsClient` wraps the ecosyste.ms APIs with 24-hour caching. `PackageInfoService` handles data extraction and normalization.

API endpoints used:
- `packages.ecosyste.ms` - Package metadata, versions, dependencies via PURL lookups
- `repos.ecosyste.ms` - Repository metadata, manifests, dependency analysis
- `advisories.ecosyste.ms` - Vulnerability data with CVE details
- `issues.ecosyste.ms` - Issue tracking, maintainer activity, PR metrics
- `commits.ecosyste.ms` - Commit activity, contributor analysis

Caching uses Rails.cache with a 24-hour TTL. Cache keys are MD5 hashes of the URL. Cache misses are logged for monitoring.

## Testing

```bash
# Unit tests
ruby -I test test/unit/services/

# Integration tests (requires network)
RUN_INTEGRATION_TESTS=1 ruby -I test test/integration/

# Specific integration tests
RUN_INTEGRATION_TESTS=1 ruby -I test test/integration/csv_workflow_test.rb
RUN_INTEGRATION_TESTS=1 ruby -I test test/integration/mcp_endpoint_test.rb
```

Manual testing:
```bash
curl http://localhost:3000/mcp/health

curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}'

curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": {"name": "get_authors", "arguments": {"purl": "pkg:pypi/numpy"}}}'
```

## Possible Future Work

Not currently planned, but could be interesting:

- Code signing verification
- Typosquatting detection
- Build/CI security analysis
- License compatibility analysis
- SBOM generation
- ML-based abandonment prediction

Contact ecosyste.ms about funding development of these.

## Notes

`get_unpatched_vulnerabilities` and `analyze_security_posture` return placeholder responses. They show what could be built with additional data sources.
