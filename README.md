# evtx-winlogbeat-sender 📄
PowerShell script to ship Windows EVTX logs to Elasticsearch via Winlogbeat

<!-- markdownlint-disable MD033 MD041 -->
<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&height=160&section=header&text=evtx-winlogbeat-sender&fontSize=38&fontColor=ffffff&animation=fadeIn" alt="header"/>
</p>

<div align="center">

![GitHub last commit](https://img.shields.io/github/last-commit/YOUR_USERNAME/evtx-winlogbeat-processor?logo=github)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?logo=powershell&logoColor=white)
![Winlogbeat](https://img.shields.io/badge/Winlogbeat-8.x-005571?logo=elastic&logoColor=white)
![License](https://img.shields.io/github/license/YOUR_USERNAME/evtx-winlogbeat-sender?color=blue)

</div>

---

## 🚀 What it does
Batch-ships Windows `.evtx` logs to **Elasticsearch** via **Winlogbeat** with a single PowerShell command.

---

## ⚡ Quick start
```powershell
.\scripts\evtx-winlogbeat-sender.ps1 `
    -Source "C:\Logs" `
    -WinlogbeatExe  "C:\Program Files\Winlogbeat\winlogbeat.exe" `
    -ConfigFile    "C:\Program Files\Winlogbeat\winlogbeat.yml" `
    -Verbose
