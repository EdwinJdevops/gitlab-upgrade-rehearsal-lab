.PHONY: verify

verify:
	python3 -m json.tool schemas/rehearsal-evidence-v1.schema.json >/dev/null
	@grep -RniE 'BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY' . --exclude-dir=.git && \
	  { echo 'Potential secret material reference found outside approved docs'; exit 1; } || true
	@echo 'Repository bootstrap verification passed.'
