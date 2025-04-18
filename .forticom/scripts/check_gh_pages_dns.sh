#!/usr/bin/env bash
# check_dns_gh_dns.sh
# Compare two domains for GitHub Pages + Infomaniak redirect A record setup

set -o errexit
set -o nounset
set -o pipefail

# GitHub Pages A records
GITHUB_IPS=("185.199.108.153" "185.199.109.153" "185.199.110.153" "185.199.111.153")

# Known Infomaniak redirect IPs (can add more if needed)
INFOMANIAK_IPS=("84.16.66.66" "84.16.67.66")

function main() {
  local domains=("${@:-forticom.co swiftboot.dev}")

  for domain in "${domains[@]}"; do
    echo -e "\n=============================="
    echo -e "🔧 Verifying domain: \033[1m${domain}\033[0m"
    echo -e "=============================="
    check_apex_records "${domain}"
    check_www_records "${domain}"
  done
}

function check_apex_records() {
  local domain="${1}"
  echo -e "\n🔍 Checking A records for \033[1m${domain}\033[0m"
  local found=false
  for ip in $(dig +short "${domain}" A); do
    if [[ " ${GITHUB_IPS[*]} " == *" ${ip} "* ]]; then
      echo "✅ ${ip} is a valid GitHub Pages IP"
      found=true
    else
      echo "❌ ${ip} is NOT a GitHub Pages IP"
    fi
  done
  if [[ "${found}" == false ]]; then
    echo "⚠️  No valid GitHub Pages A records found for ${domain}"
  fi
}

function check_www_records() {
  local domain="www.${1}"
  echo -e "\n🔍 Checking A records for \033[1m${domain}\033[0m"
  local found=false
  for ip in $(dig +short "${domain}" A); do
    if [[ " ${INFOMANIAK_IPS[*]} " == *" ${ip} "* ]]; then
      echo "✅ ${ip} is a known Infomaniak redirect IP"
      found=true
    else
      echo "❌ ${ip} is not an Infomaniak redirect IP"
    fi
  done
  if [[ "${found}" == false ]]; then
    echo "⚠️  No valid Infomaniak A records found for ${domain}"
  fi
}

main "${@:-forticom.co swiftboot.dev}"
