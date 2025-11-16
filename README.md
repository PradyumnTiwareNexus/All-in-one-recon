# All-in-one-recon
Advanced Bug Bounty Recon Tool by PradyumnTiwareNexus (Version 2.1)
# ⚡ Recon Pipeline Enhanced v2.1

### **Created by: PradyumnTiwareNexus 🇮🇳**

<div align="center">
  <img src="https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExNHV2eXMwMWVrNjFwODdvaTh5YmtieGQ3M2syNXYyZG1qbHY1c2M3bCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/RgzryV9nRCMHPVVXPV/giphy.gif" width="450" />
  <br>
  <b>"The Ultimate Automated Bug Bounty Recon Framework"</b>
</div>

---

## 🚀 Introduction

**Recon Pipeline Enhanced v2.1** is an advanced, fully automated reconnaissance framework inspired by:

* CoffinXP methodology
* Godfather-style deep recon
* Modern CDX Wayback machine extraction
* JS secret hunting pipelines
* Passive + Light Active recon techniques

Designed for **Bug Bounty Hunters**, **Security Researchers**, and **Pentesters**.

---

## 🎯 Features

✔ Automatic Subdomain Enumeration (multi-tool)
✔ Live Host Detection (httpx)
✔ JS Enumeration + Secret Extraction
✔ Wayback Machine CDX Harvesting
✔ GF Pattern Scanning
✔ Extract Endpoints + Params
✔ Nuclei Target Preparation
✔ Aggressive Mode (katana / hakrawler support)
✔ Clean Output Files:

```
live-subdomain.txt
js.txt
js-sensitive.txt
httpx-detection.txt
gf_output.txt
nuclei_targets.txt
params.txt
```

---

## 🖥️ Demo Tool ⚙

<div align="center" style="margin-top:4px; margin-bottom:8px;">

  <!-- IMAGE 1 -->
  <img src="1.png" width="720" style="
    display:block;
    margin: 6px auto;
    border-radius:10px;
    border:1px solid rgba(255,255,255,0.06);
    box-shadow: 0 8px 30px rgba(0, 140, 200, 0.12);
    max-width:100%;
  " />

  <!-- small tight gap -->
  <div style="height:8px"></div>

  <!-- IMAGE 2 -->
  <img src="2.png" width="720" style="
    display:block;
    margin: 6px auto;
    border-radius:10px;
    border:1px solid rgba(255,255,255,0.06);
    box-shadow: 0 8px 30px rgba(0, 140, 200, 0.12);
    max-width:100%;
  " />

  <!-- tightened gap before caption -->
  <div style="height:10px"></div>

  <!-- GLASS EFFECT CAPTION -->
  <div style="
      display:inline-block;
      font-size:20px;
      font-weight:600;
      line-height:1.25;
      color: #dff6ff;
      padding:10px 22px;
      border-radius:12px;
      background: linear-gradient(180deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01));
      border: 1px solid rgba(255,255,255,0.08);
      box-shadow: 0 8px 30px rgba(0,160,230,0.18), inset 0 1px 0 rgba(255,255,255,0.02);
      backdrop-filter: blur(6px);
      -webkit-backdrop-filter: blur(6px);
      text-shadow: 0 2px 14px rgba(0,160,230,0.18);
      max-width:92%;
      text-align:center;
  ">
    <span style="color:#a7f0ff; font-size:20px; font-weight:700;">
      "Full Pipeline — Subdomains → HTTPX → JS → Secrets → Nuclei Target Prep"
    </span>
  </div>

</div>

---

## 🔧 Usage (HELP GUIDE)

Below is the **official HELP section** for your tool — simple, clear, professional, and fully ready for GitHub.

---

# 🆘 HELP — How to Use This Tool

This tool is a **12‑level advanced recon automation pipeline** for bug bounty and pentesting.
It performs subdomain enumeration → live detection → JS extraction → secret finding → Wayback artifacts → GF patterns → nuclei prep.

You can run it in **Normal Mode** or **Aggressive Mode**.

---
# 🔧 Installation

Follow these steps to install and run **All-in-one-recon v2.1**:

---

### **1️⃣ Clone the repository**

```bash
git clone https://github.com/PradyumnTiwareNexus/All-in-one-recon.git
```
📂 Enter the tool directory

```bash
cd All-in-one-recon
```

## 📌 Basic Commands

### **1️⃣ Make script executable:**

```bash
chmod +x recon_pipeline_enhanced.sh
```

### **2️⃣ Run on any domain:**

```bash
./recon_pipeline_enhanced.sh target.com
```

This generates a folder like:

```
recon_target.com_2025-11-15_130600/
```

Inside this folder your full recon results will be stored.

---

## 🚀 Aggressive Mode (Deep Recon)

If you want deeper enumeration:

* katana
* hakrawler
* deeper JS extraction
* more wayback scraping

Run:

```bash
./recon_pipeline_enhanced.sh target.com --aggressive
```

Aggressive mode is more resource‑intensive — use carefully.

---

## 📁 Output Files Explained (HELP)

Each file has a purpose. Here is a full explanation:

### **🟩 1. live-subdomain.txt**

* List of ONLY live URLs.
* All dead endpoints already removed.
* Used for JS extraction, GF patterns, nuclei, etc.

### **🟦 2. httpx-detection.txt**

Contains:

* URL
* HTTP Status Code
* Page Title
* Technology stack

Example:

```
https://api.example.com [200] | "Login API" | cloudflare, nginx, react
```

### **🟧 3. js.txt**

* Extracted JS URLs from:

  * HTML source
  * Inline references
  * historical JS (gau)
  * aggressive mode (katana)

### **🟥 4. js_files/**

A folder containing downloaded JS files for analysis.

### **🟨 5. js-sensitive.txt**

All secrets found inside JS files:

* apiKey
* tokens
* jwt
* client_secret
* smtp creds
* AWS keys
* passwords

### **🟦 6. gf_output.txt**

GF patterns output for:

* XSS
* SSRF
* SQLi
* RCE
* Redirects
* LFI

Used to investigate deeper.

### **🟫 7. params.txt**

Extracted useful parameters from JS files.
Great for:

* param fuzzing
* bypass hunting
* endpoint cleanup

### **🟪 8. nuclei_targets.txt**

* Ready-to-run list for nuclei.
* Clean domains without http/https.

Run nuclei:

```bash
nuclei -l nuclei_targets.txt -t cves/ -o nuclei_output.txt
```

---

## 🧪 Example Workflow (Step-by-Step)

Here is how you typically use the tool:

### **Step 1 — Recon**

```bash
./recon_pipeline_enhanced.sh example.com
```

### **Step 2 — Review Live Domains**

```bash
cat live-subdomain.txt
```

### **Step 3 — Check JS Secrets**

```bash
cat js-sensitive.txt
```

If secrets found → report responsibly.

### **Step 4 — Run GF patterns**

```bash
cat gf_output.txt
```

### **Step 5 — Run nuclei**

```bash
nuclei -l nuclei_targets.txt -t /path/to/templates -o nuclei_output.txt
```

### **Step 6 — Optional: Wayback Check**

```bash
cat wayback_filtered.txt
```

---

## 🤖 How It Works (Internal Logic)

The tool works in 12 stages:

1. Subfinder (subdomains)
2. Amass passive
3. Assetfinder
4. Sublist3r
5. Chaos
6. Merge all + dedupe
7. httpx active scan
8. JS extraction
9. JS secret detection
10. Wayback CDX harvesting
11. GF pattern scans
12. Prepare nuclei targets

Everything automated, optimized, clean output.

---

## 🛑 IMPORTANT

* Tool is designed for **legal bug bounty programs only**.
* Never test without permission.
* Do not use discovered secrets — only report them.

---

## 🔥 Bonus Tip

Use with Google Dorks manually:

```
site:example.com "apikey"
site:github.com example "token"
```

### Aggressive Mode:

```bash
./recon_pipeline_enhanced.sh target.com --aggressive
```

---

## 📁 Output Structure

```
recon_target.com_2025-11-15_130600/
│── live-subdomain.txt
│── httpx-detection.txt
│── js.txt
│── js_files/
│── js-sensitive.txt
│── gf_output.txt
│── params.txt
│── nuclei_targets.txt
│── pipeline.log
```

---

## 🧠 Methodology Overview

### 🟦 Level 1 — Subdomain Enumeration

* subfinder
* amass
* assetfinder
* sublist3r
* chaos (if installed)

### 🟧 Level 2 — Live Host Detection

* httpx (tech, title, status)

### 🟦 Level 3 — JS Discovery

* HTML parsing
* inline JS detection
* historical JS (gau)

### 🟧 Level 4 — Secret Extraction

* rg for tokens (apiKey, jwt, credentials, smtp, aws, etc.)

### 🟦 Level 5 — Wayback CDX Harvesting

* CDX archive extraction
* uro normalization
* sensitive-file filtering

### 🟧 Level 6 — GF Pattern Matching

* ssrf, xss, redirect, sqli, rce, etc.

### 🟦 Level 7 — Nuclei Target Prep

* Clean list for nuclei scanners

---

## 🛡️ License

MIT License © 2025 **Pradyumn Tiware**

---

## ❤️ Credits & Inspiration

* CoffinXP
* Godfather Recon Scripts
* ProjectDiscovery Tools
* Wayback Machine (CDX API)

---

<div align="center">
  <h2>"Stay Ethical. Stay Sharp. Stay Ahead."</h2>
</div>
