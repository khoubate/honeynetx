#!/usr/bin/env python3
import json
import os
from pathlib import Path
from markdown import markdown
from weasyprint import HTML

def load_json_data(file_path):
    """Helper function to load JSON data with error handling"""
    if not file_path.exists():
        raise FileNotFoundError(f"Results not found at {file_path}")
    with open(file_path) as f:
        return json.load(f)

def generate_reports():
    # Configure paths
    output_dir = Path(__file__).parent.parent / "outputs" / "reports"
    checkov_dir = Path(__file__).parent.parent / "outputs" / "checkov"
    prowler_dir = Path(__file__).parent.parent / "outputs" / "prowler"
    
    # Ensure directories exist
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Load security data
    checkov_data = load_json_data(checkov_dir / "checkov_results.json")
    prowler_data = load_json_data(prowler_dir / "prowler-report.json")  # Prowler's default output filename

    # Generate markdown content
    md_content = f"""# Comprehensive Security Assessment Report

## Checkov Results (Infrastructure as Code)
**Summary**:
- ✅ Passed: {checkov_data.get("summary", {}).get("passed", 0)}
- ❌ Failed: {checkov_data.get("summary", {}).get("failed", 0)}
- ⏩ Skipped: {checkov_data.get("summary", {}).get("skipped", 0)}

### Failed Infrastructure Checks
"""

    # Add Checkov findings
    for check in checkov_data.get("results", {}).get("failed_checks", []):
        md_content += f"""
**{check.get("check_id")}**  
🔹 *File*: `{check.get("file_path")}`  
🔹 *Resource*: {check.get("resource")}  
🔹 *Guidance*: {check.get("guideline", "")}  
"""

    # Add Prowler results
    md_content += f"""
## Prowler Results (Cloud Configuration)
**Scan Summary**:
- 🔍 Total Checks: {len(prowler_data)}
- ✅ Passed: {sum(1 for item in prowler_data if item.get('Status') == 'PASS')}
- ❌ Failed: {sum(1 for item in prowler_data if item.get('Status') == 'FAIL')}
- ⚠️ Warnings: {sum(1 for item in prowler_data if item.get('Status') == 'WARNING')}

### Critical Findings
"""

    # Add Prowler findings (filter for FAILed checks)
    for finding in [item for item in prowler_data if item.get('Status') == 'FAIL']:
        md_content += f"""
**{finding.get("CheckID")}** - {finding.get("Severity")} severity  
🔹 *Service*: {finding.get("Service")}  
🔹 *Region*: {finding.get("Region")}  
🔹 *Description*: {finding.get("Description")}  
🔹 *Remediation*: {finding.get("Remediation", {}).get("Recommendation", "")}  
"""

    # Save markdown
    md_file = output_dir / "security_report.md"
    with open(md_file, "w") as f:
        f.write(md_content)
    
    # Generate PDF from markdown
    html = markdown(md_content)
    pdf_file = output_dir / "security_report.pdf"
    HTML(string=html).write_pdf(pdf_file)
    
    print(f"📄 Markdown report generated at {md_file}")
    print(f"📊 PDF report generated at {pdf_file}")

if __name__ == "__main__":
    try:
        generate_reports()
    except Exception as e:
        print(f"❌ Error generating reports: {e}")
        exit(1)