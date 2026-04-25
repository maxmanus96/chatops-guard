#!/usr/bin/env bash
set -euo pipefail

section() {
  printf '\n==> %s\n' "$1"
}

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 127
  fi
}

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

need actionlint
need checkov
need python3
need ruby
need terraform

terraform_dirs=(
  infra/envs/dev
  infra/envs/dev-platform
)

for module_dir in infra/modules/aks infra/modules/network; do
  if [ -d "$module_dir" ]; then
    terraform_dirs+=("$module_dir")
  fi
done

section "Tool versions"
terraform version
printf 'checkov %s\n' "$(checkov --version)"
python3 -c 'import yaml; print(f"PyYAML {yaml.__version__}")'
ruby --version
actionlint -version

section "YAML parse with PyYAML"
python3 - <<'PY'
from pathlib import Path
import yaml

paths = sorted(Path(".github/workflows").glob("*.yaml"))
paths += sorted(Path(".github/workflows").glob("*.yml"))
dependabot = Path(".github/dependabot.yml")
if dependabot.exists():
    paths.append(dependabot)

for path in paths:
    yaml.safe_load(path.read_text())
    print(f"OK {path}")
PY

section "YAML parse with Ruby"
ruby -e 'require "yaml"; (Dir[".github/workflows/*.{yaml,yml}"] + [".github/dependabot.yml"]).select { |p| File.exist?(p) }.sort.each { |p| YAML.load_file(p); puts "OK #{p}" }'

section "GitHub Actions lint"
actionlint -shellcheck= -color

section "Terraform format"
terraform fmt -check -recursive infra

section "Terraform init and validate"
for dir in "${terraform_dirs[@]}"; do
  printf '\n-- %s\n' "$dir"
  terraform -chdir="$dir" init -backend=false -input=false
  terraform -chdir="$dir" validate
done

section "Checkov active Terraform roots"
checkov -d infra/envs/dev --framework terraform --quiet
checkov -d infra/envs/dev-platform --framework terraform --quiet

section "Local validation complete"
