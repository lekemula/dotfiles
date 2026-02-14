---
name: rails-security-audit
description: Scan Rails code for common security vulnerabilities
disable-model-invocation: false
allowed-tools: Read, Grep, Glob
---

Perform a security audit on `$ARGUMENTS`.

Scan for these vulnerability classes:

1. **Mass Assignment**: params passed directly to `create`/`update` without strong parameters, overly permissive `permit!`
2. **SQL Injection**: raw SQL with string interpolation, `where("col = '#{val}'")`
3. **XSS**: `raw`, `html_safe`, `sanitize` misuse in views/helpers
4. **IDOR**: missing authorization checks — resources fetched by `params[:id]` without scoping to `current_user`
5. **CSRF**: `skip_before_action :verify_authenticity_token` without good reason
6. **Open Redirect**: `redirect_to params[:url]` without allowlist validation
7. **Insecure Deserialization**: `Marshal.load`, `YAML.load` on user input
8. **Sensitive Data Exposure**: secrets in code, logging PII, credentials in config
9. **Missing Authentication**: controller actions without `before_action :authenticate`
10. **File Upload**: unrestricted content types, path traversal in filenames

For each finding, report: severity (Critical/High/Medium/Low), location, description, and suggested fix.
