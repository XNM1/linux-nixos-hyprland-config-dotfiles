#!/usr/bin/env sh
# Restore omp plugins + skills after copying this tree to ~/.omp (and ../.agents to ~/.agents).
# Fill in .env from agent/.env.example and the <...> placeholders in config.yml/models.yml first.
set -eu
cd "$(dirname "$0")"
[ -f agent/.env ] || cp agent/.env.example agent/.env
(cd agent && npm ci)                                    # caveman-engine wrapper
omp plugin install caveman                              # npm plugin, not a marketplace one
omp plugin marketplace add https://github.com/mattpocock/skills && omp plugin install mattpocock-skills@mattpocock
omp plugin marketplace add DietrichGebert/ponytail     && omp plugin install ponytail@ponytail

# openskills ships from nix-ai-tools; `npx skills` is the same CLI.
# It can silently skip skills in marketingskills; if so copy them from
# raw.githubusercontent.com/coreyhaines31/marketingskills/HEAD/skills/<name>/ into ~/.agents/skills/<name>/.
S=openskills
$S add actionbook/rust-skills        -g -y -s m01-ownership,m02-resource,m03-mutability,m04-zero-cost,m05-type-driven,m06-error-handling,m07-concurrency,m09-domain,m10-performance,m11-ecosystem,m12-lifecycle,m13-domain-error,m14-mental-model,m15-anti-pattern,domain-cli,domain-cloud-native,domain-embedded,domain-fintech,domain-iot,domain-ml,domain-web,coding-guidelines,unsafe-checker,rust-router
$S add anthropics/skills             -g -y -s frontend-design,webapp-testing,theme-factory
$S add coreyhaines31/marketingskills -g -y -s content-strategy,copywriting,marketing-ideas,marketing-psychology,emails,pricing,launch,social
$S add softaworks/agent-toolkit      -g -y -s crafting-effective-readmes,humanizer,mermaid-diagrams,professional-communication,skill-judge
$S add wshobson/agents               -g -y -s rust-async-patterns,terraform-module-library
$S add vercel-labs/agent-skills      -g -y -s react-best-practices
$S add vercel-labs/skills            -g -y -s find-skills
$S add knoopx/pi                     -g -y -s podman
