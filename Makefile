.PHONY: verify

verify:
	python3 -m json.tool schemas/rehearsal-evidence-v1.schema.json >/dev/null
	@if grep -RniE --exclude-dir=.git --exclude=Makefile -- '-----BEGIN ((RSA|EC) )?PRIVATE KEY-----|-----BEGIN OPENSSH PRIVATE KEY-----' .; then \
	  echo 'Potential private key material found in repository content'; \
	  exit 1; \
	fi
	@echo 'Repository verification passed.'
