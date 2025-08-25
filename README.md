# Ecosyste.ms MCP Server

A Model Control Protocol (MCP) server providing granular, field-level access to ecosyste.ms package ecosystem data. Connect this server to Claude Desktop, Claude Code, ChatGPT, or any MCP-compatible LLM to build custom package analysis workflows using raw data.

---

## 🛠️ **AVAILABLE MCP TOOLS**

### Package Metadata Tools
- **`get_package_basic_info`** - Get basic package information (id, name, ecosystem, description, homepage, licenses)
- **`get_package_dates`** - Get package creation and update dates (created_at, updated_at, first_release_published_at)
- **`get_package_repository_info`** - Get repository URL and social metrics (stars, forks)
- **`get_package_versions_info`** - Get version count and latest release info
- **`get_package_keywords`** - Get package keywords and categories
- **`get_package_urls`** - Get ecosyste.ms URLs and related links (repository_url, homepage, icon_url)
- **`get_package_metrics`** - Get package metrics including downloads, dependents, stars, forks, rankings, maintainers, and repository stats
- **`get_funding_links`** - Get funding links for a package
- **`get_latest_version`** - Get latest version information for a package

### Version-Specific Tools
- **`get_version_info`** - Get specific version metadata (published_at, downloads, author, checksum, size)
- **`get_version_dependencies`** - Get dependencies for a specific version (requires PURL with version)
- **`get_package_dependencies`** - Get dependencies for latest version of a package
- **`get_package_versions`** - Get complete list of all versions for a package with pagination support
- **`get_package_version_numbers`** - Get simple list of version numbers for a package (lightweight alternative to get_package_versions)
- **`get_related_packages`** - Get packages related to this package (dependencies, dependents, similar packages) with pagination support
- **`get_dependent_packages`** - Get packages that depend on this package with pagination support
- **`get_package_maintainers`** - Get package maintainers list with detailed information
- **`get_maintainer_packages`** - Get packages maintained by a specific maintainer
- **`get_version_urls`** - Get ecosyste.ms URLs for specific version analysis and registry links

### Repository Analysis Tools
**Note: All repository tools accept either direct repository URLs (e.g. `github.com/numpy/numpy`) or PURLs (e.g. `pkg:pypi/numpy`). When a PURL is provided, the tool automatically resolves the package's repository URL.**

- **`get_repo_basic_info`** - Get repository basic info (id, full_name, owner, description, archived, fork)
- **`get_repo_activity`** - Get repository activity metrics (pushed_at, size, last_synced_at)
- **`get_repo_community`** - Get community metrics (stars, forks, subscribers, open_issues)
- **`get_repo_metadata`** - Get repository metadata (topics, language, license, default_branch)
- **`get_repo_dependencies`** - Get dependencies from repository manifest files (Gemfile, package.json, etc.)
- **`get_repo_metafiles`** - Get list of interesting metadata files from repository info (LICENSE, README, etc.)
- **`get_repo_files`** - Get complete list of files in repository using archives API
- **`get_repo_file_contents`** - Get contents of a specific file from repository using archives API
- **`get_repo_readme`** - Get repository README content using archives API
- **`get_repo_changelog`** - Get repository changelog with parsed version entries using archives API
- **`get_repo_repomix`** - Get AI-friendly concatenated string of all repository file contents using archives API
- **`get_repo_tags`** - Get repository tags with pagination support using ecosyste.ms repos API
- **`get_repo_releases`** - Get repository releases with pagination support using ecosyste.ms repos API
- **`get_repo_sbom`** - Get repository SBOM (Software Bill of Materials) using ecosyste.ms repos API
- **`get_repo_owner`** - Get repository owner information using ecosyste.ms repos API
- **`get_repo_scorecard`** - Get repository security scorecard using ecosyste.ms repos API
- **`get_repo_urls`** - Get ecosyste.ms URLs for repository analysis across all platforms (repos, issues, commits)
- **`get_repo_package_names`** - Get package names associated with a repository

### Issue Tracking Tools
- **`get_issue_counts`** - Get issue and PR counts (total, closed)
- **`get_issue_timing`** - Get average time to close issues and PRs
- **`get_maintainer_info`** - Get maintainer lists (all-time and active)
- **`get_contributor_counts`** - Get contributor counts for PRs and issues
- **`get_past_year_activity`** - Get past year issue and PR activity

### Commit Activity Tools
- **`get_commit_overview`** - Get repository commit overview (id, full_name, default_branch)
- **`get_committer_list`** - Get complete list of committers with commit counts
- **`get_top_committers`** - Get top N committers by commit count

### Vulnerability Tools
- **`get_vulnerability_list`** - Get detailed list of all vulnerabilities with CVE details
- **`get_vulnerability_counts_by_severity`** - Get vulnerability counts grouped by severity (critical, high, moderate, low)
- **`get_latest_vulnerability_date`** - Get the date of the most recent vulnerability

### Registry Tools
- **`get_registry_list`** - Get list of all available package registries

---

## 🔌 **CONNECTING TO YOUR LLM**

### **Claude Desktop**
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

### **Claude Code (VS Code/CLI)**

**Option 1: CLI (Recommended)**
```bash
# Start the MCP server first
rails server

# Add the MCP server in one line
claude mcp add ecosystems http://localhost:3000/mcp -t http
```

**Option 2: Manual Configuration**
Add to your Claude Code settings:
```json
{
  "mcp.servers": {
    "ecosystems": {
      "url": "http://localhost:3000/mcp"
    }
  }
}
```

### **ChatGPT (Custom GPT/Actions)**
Create a new GPT Action with this OpenAPI spec:
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

### **Generic MCP Client**
Connect any MCP-compatible client to:
- **Endpoint:** `http://localhost:3000/mcp`
- **Protocol:** JSON-RPC 2.0
- **Methods:** `tools/list`, `tools/call`

---

## 💬 **EXAMPLE LLM PROMPTS**

Once connected, try these prompts:

**"Analyze numpy's dependencies and vulnerabilities"**
```
Use the MCP tools to:
1. Get basic info for pkg:pypi/numpy
2. Get its latest dependencies 
3. Check vulnerability counts by severity
4. Show the top 5 committers for the numpy/numpy repository
```

**"Compare package metadata across ecosystems"**  
```
Compare package metadata between:
- pkg:pypi/requests (Python)
- pkg:npm/axios (Node.js)
- pkg:cargo/reqwest (Rust)

Use tools to get basic info, repository metrics, and latest versions for each.
```

**"Analyze repository dependencies and activity"**
```
For github.com/microsoft/vscode:
1. Get repository community metrics
2. Get dependencies from manifest files
3. Get issue counts and timing
4. Show maintainer information
```

**"Dependency tree analysis"**
```
Get dependencies for pkg:cargo/tokio and then analyze the dependencies 
of its top 3 normal (non-dev) dependencies using the version-specific tools.
```

**"Get exploration URLs for detailed analysis"**
```
Use URL tools to get ecosyste.ms links for:
1. Package URLs for pkg:pypi/django 
2. Version URLs for pkg:cargo/serde@1.0.193
3. Repository URLs for github.com/torvalds/linux

Then visit the web interfaces for deeper exploration.
```

**"Analyze repository files and contents"**
```
For github.com/numpy/numpy:
1. Get metadata files using get_repo_metafiles (LICENSE, README, etc.)
2. Get complete file list using get_repo_files (via archives API)
3. Get README content using get_repo_readme (optimized README API)
4. Get changelog with parsed versions using get_repo_changelog
5. Get specific version changes using get_repo_changelog with version parameter
6. Get AI-friendly concatenated codebase using get_repo_repomix (for full code analysis)
7. Get contents of specific files (LICENSE, SECURITY.md) using get_repo_file_contents
8. Compare security policies across multiple repositories
```

---

## ⚡ **QUICK START**

1. **Start the server:**
```bash
git clone <this-repo>
cd mcp
bundle install
rails server
```

2. **Test the connection:**
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

3. **Connect your LLM** using the instructions above

4. **Start analyzing!** Use the example prompts or create your own package analysis workflows.

---

## 🏆 **KEY FEATURES**

### **Granular Data Access**
- **49 MCP Tools** providing raw, field-level access to ecosyste.ms data
- **No Opinions** - Tools return raw API fields, users decide what data means
- **Composable** - Mix and match tools for custom analysis workflows
- **Multi-Ecosystem Support** - PyPI, npm, Cargo, RubyGems, Maven, NuGet via PURL

### **Comprehensive Coverage**
- **Package Metadata** - Basic info, dates, repository details, versions, keywords
- **Dependencies** - Version-specific and latest dependencies for packages and repositories
- **Repository Analysis** - Activity, community metrics, manifest files
- **Issue & Commit Tracking** - Detailed maintainer and contributor activity
- **Vulnerability Data** - Detailed CVE information with severity breakdowns

### **Performance & Reliability**
- **24-Hour Caching** - All API responses cached for 24 hours for fast repeat queries
- **Robust Error Handling** - Graceful fallbacks and comprehensive logging with automatic retry logic
- **Automatic Retry Logic** - Server errors (5xx), rate limiting (429), and network timeouts automatically retried with exponential backoff
- **Full Test Coverage** - Unit tests and integration tests ensure reliability

### **LLM-Optimized Design**
- **Raw Data Focus** - Direct API field exposure for maximum flexibility
- **PURL Standard Support** - Standardized package identification across ecosystems
- **Field-Based Architecture** - Tools aligned with actual ecosyste.ms API structure

### **Production Ready**
- **JSON-RPC 2.0 Compliance** - Works with all MCP-compatible LLMs
- **Health Check Endpoint** - `/mcp/health` for monitoring
- **Comprehensive Logging** - Full request/response logging with cache hit/miss tracking

---

## 📊 **ARCHITECTURE**

### **Core Services**
- **`SimpleMcpServer`** - Main MCP server handling JSON-RPC 2.0 protocol
- **`EcosystemsClient`** - API client with 24-hour caching for all ecosyste.ms endpoints
- **`PackageInfoService`** - Data extraction and normalization logic

### **API Endpoints Used**
- **`packages.ecosyste.ms`** - Package metadata, versions, dependencies via PURL lookups
- **`repos.ecosyste.ms`** - Repository metadata, manifests, and dependency analysis
- **`advisories.ecosyste.ms`** - Vulnerability data with CVE details and severity rankings
- **`issues.ecosyste.ms`** - Repository issue tracking, maintainer activity, and PR metrics
- **`commits.ecosyste.ms`** - Commit activity, contributor analysis, and committer rankings

### **Caching Strategy**
- **Cache Key:** `ecosystems_api:{MD5_of_URL}`
- **TTL:** 24 hours for all responses
- **Cache Misses:** Logged for monitoring API usage
- **Storage:** Uses Rails.cache (configurable backend)

---

## 🧪 **TESTING**

### Prerequisites
- Ruby 3.4.5+
- Rails 8.0.2+
- Bundler

### Installation
```bash
bundle install
rails server
```

### Running Tests
```bash
# Unit tests
ruby -I test test/unit/services/

# Integration tests (requires network)
RUN_INTEGRATION_TESTS=1 ruby -I test test/integration/

# Specific integration tests
RUN_INTEGRATION_TESTS=1 ruby -I test test/integration/csv_workflow_test.rb
RUN_INTEGRATION_TESTS=1 ruby -I test test/integration/mcp_endpoint_test.rb
```

### Manual Testing
```bash
# Health check
curl http://localhost:3000/mcp/health

# List all tools
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}'

# Test individual tools
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": {"name": "get_authors", "arguments": {"purl": "pkg:pypi/numpy"}}}'
```

---

## 🔮 **POTENTIAL ENHANCEMENTS**

These features could extend the system but are not currently planned:

### Advanced Security Analysis
- **Code signing verification** - Check package signing practices
- **Typosquatting detection** - Identify similar malicious packages  
- **Build security analysis** - CI/CD pipeline security analysis
- **2FA enforcement tracking** - Maintainer 2FA status verification

### Enhanced Intelligence
- **ML-based abandonment prediction** - Predict package abandonment risk
- **Behavioral anomaly detection** - Identify unusual release patterns
- **Dependency confusion analysis** - Detect potential attack vectors
- **Threat intelligence integration** - External threat feed integration

### Compliance & Legal
- **License compatibility analysis** - Check license conflicts
- **Export control compliance** - Check for export restrictions
- **SBOM generation** - Software Bill of Materials creation
- **Compliance reporting** - Generate reports for frameworks

**Contact ecosyste.ms about funding development of these advanced capabilities.**

---

## 📝 **NOTES**

### **Pending Features**
- `get_unpatched_vulnerabilities` and `analyze_security_posture` return structured "pending_feature_required" responses
- These placeholders demonstrate potential enhanced capabilities
- Actual implementation would require additional data sources and analysis infrastructure

---

## 🤝 **CONTRIBUTING**

This is a production-ready MCP server. All core functionality is implemented and tested. Future enhancements should focus on:

1. **Performance optimization** - Further caching improvements
2. **Data source expansion** - Additional API integrations  
3. **Analysis enhancement** - More sophisticated risk models
4. **Ecosystem expansion** - Support for additional package registries

---

## 📊 **ARCHITECTURE NOTES**

### **Caching Strategy Rationale**
- **24-hour TTL** balances data freshness with API rate limiting
- **URL-based cache keys** ensure deterministic caching behavior
- **Cache miss logging** enables monitoring and optimization
- **Rails.cache integration** allows flexible backend configuration

### **Multi-Ecosystem PURL Support**
- Uses standard PURL (Package URL) format for ecosystem-agnostic package identification
- Supports mapping between PURL types and ecosyste.ms registry names
- Handles URL encoding and special characters correctly
- Future-proof for additional package ecosystems