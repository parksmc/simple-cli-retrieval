# Codex Settlement Agreement Analysis Demo

Demonstrates parallel agentic retrieval using codex's experimental prompt field feature.

## Overview

This demo shows how to run multiple specialized codex instances in parallel, each extracting specific information from a settlement agreement for administrative purposes.

## Structure

```
codex-settlement-demo/
├── prompts/                    # Specialized extraction prompts
│   ├── payment_terms.md
│   ├── key_dates.md
│   ├── parties_and_roles.md
│   ├── confidentiality.md
│   ├── release_and_liability.md
│   ├── compliance_obligations.md
│   └── dispute_resolution.md
├── analyze_settlement.sh       # Main execution script
└── README.md
```

## Usage

Run the analysis script with your settlement agreement:

```bash
./analyze_settlement.sh /path/to/contract.md
```

Or from the parent directory:

```bash
cd codex-settlement-demo
./analyze_settlement.sh ../contract.md
```

## What It Does

1. Creates a datestamped output folder (e.g., `results_2025-10-22_14-30-45/`)
2. Launches 7 parallel codex instances, each with a specialized prompt
3. Each instance analyzes the same settlement agreement for specific information
4. Results are saved to separate markdown files in the output folder

## Prompt Specializations

Each prompt file asks a focused extraction question:

- **payment_terms.md** - Extract the total settlement amount
- **key_dates.md** - Extract the first payment due date
- **parties_and_roles.md** - Extract plaintiff and defendant names
- **confidentiality.md** - Extract what information must be kept confidential
- **release_and_liability.md** - Extract what claims are being released
- **compliance_obligations.md** - Extract document destruction requirements
- **dispute_resolution.md** - Extract the dispute resolution method

## Output

All results are saved to a timestamped directory with files named:
- `payment_terms_result.md`
- `key_dates_result.md`
- `parties_and_roles_result.md`
- `confidentiality_result.md`
- `release_and_liability_result.md`
- `compliance_obligations_result.md`
- `dispute_resolution_result.md`

## Example

```bash
$ ./analyze_settlement.sh ../contract.md

===================================
Settlement Agreement Analysis
===================================
Input file: ../contract.md
Output directory: results_2025-10-22_14-30-45
Starting parallel analysis...

→ Starting analysis: Payment Terms
→ Starting analysis: Key Dates & Deadlines
→ Starting analysis: Parties & Roles
→ Starting analysis: Confidentiality
→ Starting analysis: Release & Liability
→ Starting analysis: Compliance Obligations
→ Starting analysis: Dispute Resolution

All analyses launched. Waiting for completion...
```

## Customization

To add new analysis types:

1. Create a new prompt file in `prompts/` directory with a focused extraction question
2. Add an entry to the `analyses` array in `analyze_settlement.sh` (format: "prompt_name:Description")
3. Run the script - it will automatically include the new analysis

## Requirements

- [Codex CLI](https://docs.codex.anthropic.com/) installed and authenticated
- Bash shell (compatible with bash 3.2+, works on macOS and Linux)
- A markdown-formatted document to analyze (use [MarkItDown](https://github.com/microsoft/markitdown) to convert PDFs and other formats)
