#!/usr/bin/env bash
set -euo pipefail

umask 077

output_dir="${1:-baseline-capture}"
files_dir="${output_dir}/files"
manifest="${output_dir}/manifest.tsv"

mkdir -p "${files_dir}"
printf 'retrieved_at_utc\tname\tbytes\tsha256\turl\n' > "${manifest}"

fetch_one() {
  local name="$1"
  local url="$2"
  local path="${files_dir}/${name}"
  local retrieved_at bytes sha256

  retrieved_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --proto '=https' \
    --tlsv1.2 \
    --retry 3 \
    --retry-all-errors \
    --connect-timeout 15 \
    --max-time 60 \
    --output "${path}" \
    "${url}"

  if [[ ! -s "${path}" ]]; then
    echo "baseline capture failed: ${name} is empty" >&2
    exit 1
  fi

  bytes="$(wc -c < "${path}" | tr -d '[:space:]')"
  sha256="$(sha256sum "${path}" | awk '{print $1}')"

  printf '%s\t%s\t%s\t%s\t%s\n' \
    "${retrieved_at}" \
    "${name}" \
    "${bytes}" \
    "${sha256}" \
    "${url}" \
    >> "${manifest}"
}

fetch_one \
  'upgrade_path.yml' \
  'https://gitlab.com/gitlab-org/gitlab/-/raw/master/config/upgrade_path.yml'

fetch_one \
  'path.json' \
  'https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/path.json'

fetch_one \
  'alerts.yml' \
  'https://gitlab.com/gitlab-com/support/toolbox/upgrade-path/-/raw/main/alerts.yml'

# Fail closed on obvious transport/error-page corruption. These are shape checks,
# not semantic validation of GitLab's upgrade rules.
python3 -m json.tool "${files_dir}/path.json" >/dev/null

awk '
  $1 == "-" && $2 == "major:" { major = $3 }
  $1 == "minor:" && major == 19 && $2 == 2 { found = 1 }
  END { exit(found ? 0 : 1) }
' "${files_dir}/upgrade_path.yml" || {
  echo 'baseline capture failed: upgrade_path.yml does not contain GitLab 19 / minor 2 required-stop entry' >&2
  exit 1
}

grep -Eq 'severity:|check_when:|requires_version:' "${files_dir}/alerts.yml" || {
  echo 'baseline capture failed: alerts.yml does not resemble Support upgrade-alert data' >&2
  exit 1
}

cat "${manifest}"
