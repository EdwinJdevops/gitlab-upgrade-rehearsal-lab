# Security policy

Do not test this repository against a production GitLab instance except for explicitly read-only inventory operations that have been reviewed and documented.

Do not submit real GitLab backups, `gitlab-secrets.json`, credentials, CI/CD variables, private repositories, access tokens, SSH keys, or production database dumps in issues or pull requests.

For the research phase, use synthetic or sanitized fixtures only.

Security-sensitive defects should not be demonstrated with live third-party systems. Provide the minimum safe reproduction and affected code path.
