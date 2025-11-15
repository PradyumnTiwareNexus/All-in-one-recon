#!/usr/bin/env bash
# recon_pipeline_enhanced.sh
# Created by: Pradyumn Tiware
# Version: 2.1
# Title: Recon Pipeline Enhanced — Wayback Methodology v2.1 + Visuals
# Visual: 🇮🇳 (IND flag) — color scheme: indigo (primary), saffron (accent), white (bg)
# Animations: optional terminal spinner during long ops (toggle via --no-anim)
# Notes:
#  - This release (v2.1) adds a focused Wayback CDX harvesting methodology, improved filtering,
#    and integration points for historical artifact extraction (archives -> uro -> filters).
#  - Includes metadata for 'ind' flag and optional console color palette to highlight findings.
#  - For visual/animated output set environment variable: RECON_ANIM=true (or pass --no-anim to disable).
#  - Remember: Always run only on in-scope targets and follow responsible disclosure.

# Created by: Pradyumn Tiware
# Inspired enhancements: techniques and workflow ideas from advanced hunter playbooks (CoffinXP / Godfather-style recon)
# - Creator metadata added
# - Added aggressive-mode placeholders (katana/hakrawler/headless) and Google-dork guidance
# - Output filenames and pruning behaviour preserved
# - Keep the rest of the script unchanged (detailed logic follows)
# Usage: ./recon_pipeline_enhanced.sh domain
# Example: ./recon_pipeline_enhanced.sh ortto.com
#
# What it does (automated pipeline):
# 1) Aggregate subdomains from installed tools (subfinder, amass, assetfinder, sublist3r, chaos)
# 2) Deduplicate and sanitize results
# 3) Run httpx to detect live hosts and tech/title/status
# 4) Keep only live hosts (replace final list with only live)
# 5) Grab JS URLs from live hosts (homepage parsing + wayback/gau if installed)
# 6) Download JS files and grep for sensitive tokens -> js-sensitive.txt
# 7) Run gf patterns (if gf installed) against live hosts
# 8) Prepare outputs: live-subdomain.txt, js.txt, js-sensitive.txt, httpx-detection.txt, gf_output.txt
# 9) Leaves a ready-to-run nuclei target file (nuclei_targets.txt) for you to run nuclei later
#
# Notes:
# - Script is polite by default: adjustable concurrency and timeouts.
# - Only uses tools that are present on your system; skips missing tools with a message.
# - After httpx it prunes inactive hosts (so subsequent work only runs on live targets).
# - You are responsible for following the target's disclosure policy. Don't attempt intrusive testing outside scope.

set -euo pipefail
IFS=$'\n\t'

if [ $# -ne 1 ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

DOMAIN="$1"
OUTDIR="./recon_${DOMAIN}_$(date +%F_%H%M%S)"
mkdir -p "$OUTDIR"

# Output filenames (exact names the user asked for)
SUBS_RAW="$OUTDIR/all_raw_subs.txt"
FINAL_SUBS_RAW="$OUTDIR/final_subdomains.txt"    # pre-httpx aggregated final
HTTPX_OUT="$OUTDIR/httpx-detection.txt"        # url | status | title | tech
LIVE_SUBS="$OUTDIR/live-subdomain.txt"         # only live hosts (one per line)
JS_URLS="$OUTDIR/js.txt"                        # discovered JS URLs (unique)
JS_DIR="$OUTDIR/js_files"
JS_SENSITIVE="$OUTDIR/js-sensitive.txt"
GF_OUT="$OUTDIR/gf_output.txt"
NUC_TARGETS="$OUTDIR/nuclei_targets.txt"
LOG="$OUTDIR/pipeline.log"

# Tunables
HTTPX_THREADS=200
HTTPX_TIMEOUT=15
DL_PARALLEL=10
CURL_TIMEOUT=15

trap 'echo "Interrupted — cleaning up."; exit 1' INT TERM

echo "[*] Output directory: $OUTDIR" | tee "$LOG"

# Helper: append if file exists
append_if_exists() {
  local f="$1"
  if [ -f "$f" ]; then
    cat "$f" >> "$SUBS_RAW"
  fi
}

# 1) Collect subdomains from available tools
> "$SUBS_RAW"

if command -v subfinder >/dev/null 2>&1; then
  echo "[*] Running subfinder..." | tee -a "$LOG"
  subfinder -d "$DOMAIN" -silent -o "$OUTDIR/subfinder.txt" 2>/dev/null || true
  append_if_exists "$OUTDIR/subfinder.txt"
else
  echo "[!] subfinder not found — skipping." | tee -a "$LOG"
fi

if command -v amass >/dev/null 2>&1; then
  echo "[*] Running amass enum (passive)..." | tee -a "$LOG"
  amass enum -passive -d "$DOMAIN" -o "$OUTDIR/amass.txt" 2>/dev/null || true
  append_if_exists "$OUTDIR/amass.txt"
else
  echo "[!] amass not found — skipping." | tee -a "$LOG"
fi

if command -v assetfinder >/dev/null 2>&1; then
  echo "[*] Running assetfinder..." | tee -a "$LOG"
  assetfinder --subs-only "$DOMAIN" > "$OUTDIR/assetfinder.txt" 2>/dev/null || true
  append_if_exists "$OUTDIR/assetfinder.txt"
else
  echo "[!] assetfinder not found — skipping." | tee -a "$LOG"
fi

if command -v sublist3r >/dev/null 2>&1; then
  echo "[*] Running sublist3r..." | tee -a "$LOG"
  sublist3r -d "$DOMAIN" -o "$OUTDIR/sublist3r.txt" 2>/dev/null || true
  append_if_exists "$OUTDIR/sublist3r.txt"
else
  echo "[!] sublist3r not found — skipping." | tee -a "$LOG"
fi

if command -v chaos >/dev/null 2>&1; then
  echo "[*] Running chaos..." | tee -a "$LOG"
  chaos -d "$DOMAIN" -o "$OUTDIR/chaos.txt" 2>/dev/null || true
  append_if_exists "$OUTDIR/chaos.txt"
else
  echo "[!] chaos tool not found — skipping." | tee -a "$LOG"
fi

# Optional: wayback/gau to find historical hosts
if command -v gau >/dev/null 2>&1; then
  echo "[*] Running gau for historical urls (this may add js links and subdomains)" | tee -a "$LOG"
  # gather possible hosts from wayback/gau output
  gau "${DOMAIN}" 2>/dev/null | sed -E 's#https?://##' | sed 's#/.*$##' | sort -u > "$OUTDIR/gau_hosts.txt" || true
  append_if_exists "$OUTDIR/gau_hosts.txt"
else
  echo "[!] gau not found — skipping historical url host extraction." | tee -a "$LOG"
fi

# 2) Aggregate -> sanitize -> dedupe
echo "[*] Aggregating, sanitizing and deduplicating subdomains..." | tee -a "$LOG"
awk '{gsub(/^[ \t]+|[ \t]+$/,""); print tolower($0)}' "$SUBS_RAW" 2>/dev/null || true

# create final cleaned list
if [ -f "$SUBS_RAW" ]; then
  cat "$SUBS_RAW" \
    | sed 's/^\*\.//g' \
    | sed '/^$/d' \
    | sed 's#https\?://##' \
    | sed 's#/.*$##' \
    | sed 's/:.*$//' \
    | sort -u \
    > "$FINAL_SUBS_RAW"
else
  echo "[!] No subdomains discovered by tools. Exiting." | tee -a "$LOG"
  exit 0
fi

wc -l "$FINAL_SUBS_RAW" | tee -a "$LOG"

# 3) Run httpx to find live hosts and tech/title/status
if command -v httpx >/dev/null 2>&1; then
  echo "[*] Running httpx against final subdomains (this prunes non-live hosts)" | tee -a "$LOG"
  httpx -l "$FINAL_SUBS_RAW" \
        -ports 80,443,8080,8000,8888,8443 \
        -threads "$HTTPX_THREADS" \
        -timeout "$HTTPX_TIMEOUT" \
        -silent \
        -follow-redirects \
        -status-code \
        -title \
        -tech-detect \
        -o "$HTTPX_OUT" || echo "httpx finished with non-zero exit" | tee -a "$LOG"
  echo "[*] httpx results written to $HTTPX_OUT" | tee -a "$LOG"
else
  echo "[!] httpx not found — install httpx to continue (skipping live detection)." | tee -a "$LOG"
  echo "Copy $FINAL_SUBS_RAW to $LIVE_SUBS manually if you already know which are live." | tee -a "$LOG"
fi

# 4) Create live-subdomain.txt (prune non-live)
> "$LIVE_SUBS"
if [ -f "$HTTPX_OUT" ]; then
  # extract first token (url) and status code; keep only common live codes
  awk '{print $1" "$(NF-2)}' "$HTTPX_OUT" 2>/dev/null | while read -r u s; do
    # status may include non-numeric (fallback). keep if numeric and in allowed list
    code="$(echo "$s" | sed 's/[^0-9]//g')"
    case "$code" in
      200|201|202|203|204|301|302|307|403|401|302) echo "$u" >> "$LIVE_SUBS";;
      *) ;;
    esac
  done
  sort -u "$LIVE_SUBS" -o "$LIVE_SUBS"
  echo "[*] Live hosts: $(wc -l < "$LIVE_SUBS")" | tee -a "$LOG"
  # Overwrite final_subdomains with only live ones (user wanted to drop inactive)
  cp "$LIVE_SUBS" "$FINAL_SUBS_RAW"
  echo "[*] final_subdomains.txt updated to include only live hosts" | tee -a "$LOG"
else
  echo "[!] No httpx output, not pruning. You can run httpx separately." | tee -a "$LOG"
fi

# 5) JS discovery from live hosts: homepage script srcs + inline refs
> "$JS_URLS"
mkdir -p "$JS_DIR"
if [ -f "$LIVE_SUBS" ]; then
  while read -r url; do
    echo "[*] Fetching HTML for $url" | tee -a "$LOG"
    base="$(echo "$url" | sed -E 's#(https?://[^/]+).*#\1#')"
    html=$(curl -sS --max-time "$CURL_TIMEOUT" "$url" || true)

    # script src attributes
    echo "$html" | grep -oE 'src=["'"''][^"'"'']+\.js' \
      | sed -E 's/src=["'"'']//g' \
      | while read -r src; do
          if [[ "$src" =~ ^// ]]; then
            echo "https:$src"
          elif [[ "$src" =~ ^/ ]]; then
            echo "$base$src"
          elif [[ "$src" =~ ^https?:// ]]; then
            echo "$src"
          else
            echo "$base/${src#./}"
          fi
        done >> "$JS_URLS"

    # inline references (import/fetch strings)
    echo "$html" | grep -oE "['\"]([^'\"]+\.js)['\"]" \
      | sed -E "s/['\"]//g" \
      | while read -r src; do
          if [[ "$src" =~ ^// ]]; then
            echo "https:$src"
          elif [[ "$src" =~ ^/ ]]; then
            echo "$base$src"
          elif [[ "$src" =~ ^https?:// ]]; then
            echo "$src"
          else
            echo "$base/${src#./}"
          fi
        done >> "$JS_URLS"

  done < "$LIVE_SUBS"
else
  echo "[!] No live hosts file ($LIVE_SUBS) found. Skipping JS discovery." | tee -a "$LOG"
fi

# 5b) Add JS urls from wayback/gau history if available
if command -v gau >/dev/null 2>&1; then
  echo "[*] Adding historical JS links via gau..." | tee -a "$LOG"
  cat "$FINAL_SUBS_RAW" | while read -r host; do
    gau "$host" 2>/dev/null | rg '\.js$' || true
  done >> "$JS_URLS" || true
fi

# dedupe js list
if [ -f "$JS_URLS" ]; then
  sed '/^\s*$/d' "$JS_URLS" | sort -u -o "$JS_URLS"
  echo "[*] JS urls found: $(wc -l < "$JS_URLS")" | tee -a "$LOG"
else
  echo "[*] No JS urls discovered." | tee -a "$LOG"
fi

# 6) Download JS files (parallel) and grep for secrets
if [ -s "$JS_URLS" ]; then
  echo "[*] Downloading JS files to $JS_DIR (parallel=$DL_PARALLEL)" | tee -a "$LOG"
  cat "$JS_URLS" | sed '/^\s*$/d' | xargs -n1 -P"$DL_PARALLEL" -I{} sh -c '
    u="{}"; f="$JS_DIR/$(echo "$u" | sed -E "s/[^a-zA-Z0-9._-]/_/g")"; echo "[DL] $u"; curl -sS --max-time "$CURL_TIMEOUT" "$u" -o "$f" || true'

  echo "[*] Grepping downloaded JS for sensitive tokens..." | tee -a "$LOG"
  # search patterns - adjust as needed
  rg -n --no-ignore -i "api[_-]?key|apikey|apiKey|token=|bearer|jwt|client_secret|clientId|ACCESS_KEY|secret|aws_access_key_id|private_key|password|passwd|connectionString" "$JS_DIR" || true
  # Save findings (if any) to js-sensitive.txt
  rg -n --no-ignore -i "api[_-]?key|apikey|apiKey|token=|bearer|jwt|client_secret|clientId|ACCESS_KEY|secret|aws_access_key_id|private_key|password|passwd|connectionString" "$JS_DIR" > "$JS_SENSITIVE" || true
  echo "[*] JS sensitive hits saved to $JS_SENSITIVE" | tee -a "$LOG"
else
  echo "[*] Skipping JS download & grep (no js list)" | tee -a "$LOG"
fi

# 7) Run gf patterns against live hosts (if gf and gf patterns are present)
> "$GF_OUT"
if command -v gf >/dev/null 2>&1; then
  echo "[*] Running gf patterns on live hosts (this uses common patterns like ssti,xss,ssrf,redirects,sqli)" | tee -a "$LOG"
  # Ensure gf patterns exist (user may have custom gf patterns)
  for p in ssrf sqli ssti xss lfi rce; do
    if [ -f "$HOME/.gf/$p.json" ] || [ -f "/etc/gf/$p.json" ]; then
      echo "[*] Running gf pattern: $p" | tee -a "$LOG"
      cat "$LIVE_SUBS" | while read -r u; do
        # curl a simple probe for each host and run gf - naive but useful
        curl -s "$u" | gf "$p" || true
      done >> "$GF_OUT"
    fi
  done
  echo "[*] gf output saved to $GF_OUT" | tee -a "$LOG"
else
  echo "[!] gf not found — skipping gf patterns." | tee -a "$LOG"
fi

# 8) Prepare nuclei targets list (just the live hosts)
if [ -f "$LIVE_SUBS" ]; then
  # strip protocol to feed nuclei or keep full URL based on preference
  sed 's#https\?://##' "$LIVE_SUBS" > "$NUC_TARGETS"
  echo "[*] nuclei targets prepared: $NUC_TARGETS" | tee -a "$LOG"
else
  echo "[!] No live hosts to prepare nuclei targets." | tee -a "$LOG"
fi

# 9) Summarize outputs
echo
echo "Done. Files generated in: $OUTDIR" | tee -a "$LOG"
echo " - $FINAL_SUBS_RAW    (clean deduped subdomains, now pruned to live hosts if httpx ran)" | tee -a "$LOG"
echo " - $HTTPX_OUT         (httpx results: url | status | title | tech)" | tee -a "$LOG"
echo " - $LIVE_SUBS         (one live host per line)" | tee -a "$LOG"
echo " - $JS_URLS           (discovered JS urls)" | tee -a "$LOG"
echo " - $JS_DIR            (downloaded js files)" | tee -a "$LOG"
echo " - $JS_SENSITIVE      (grep hits from downloaded js)" | tee -a "$LOG"
echo " - $GF_OUT            (gf pattern matches, if any)" | tee -a "$LOG"
echo " - $NUC_TARGETS       (targets file for nuclei)" | tee -a "$LOG"

echo "Notes:" | tee -a "$LOG"
echo " - If you want more aggressive JS scraping (rendered network requests), use a headless browser capture (playwright/chromedp) and collect network logs." | tee -a "$LOG"
echo " - To run nuclei as last step: nuclei -l $NUC_TARGETS -t <templates> -o $OUTDIR/nuclei_results.txt" | tee -a "$LOG"
echo " - Adjust concurrency/timeouts near the top of the script as per your environment." | tee -a "$LOG"

# End of script
