# Simple CLI Retrieval with Codex

Demonstrates parallel agentic retrieval using codex's experimental prompt field feature.

## Overview

This demo shows how to run multiple specialized Codex CLI instances in parallel, each extracting specific information from documents. The included prompts are tailored for contract analysis as a simple example use case, but the pattern works for any type of office document.

## Structure

```
simple-cli-retrieval/
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

Run the analysis script with your document (markdown format):

```bash
./analyze_settlement.sh /path/to/document.md
```

The included prompts are designed for contract documents, but you can customize them for any document type (financial reports, legal briefs, meeting notes, etc.).

## How It Works

1. Creates a datestamped output folder (e.g., `results_2025-10-22_14-30-45/`)
2. Launches 7 parallel Codex CLI instances, each with a specialized prompt
3. Each instance analyzes the same document for specific information
4. Results are saved to separate markdown files in the output folder

## Example Prompts (Class Action Settlement Focus)

The included prompts target key information from class action settlements:

- **payment_terms.md** - Settlement amount and how money is distributed to class members
- **key_dates.md** - Top 3 most meaningful dates and their significance
- **parties_and_roles.md** - Who is eligible to be part of the settlement class
- **confidentiality.md** - What the lawsuit was about (synthesize allegations)
- **release_and_liability.md** - What claims class members are releasing
- **compliance_obligations.md** - How to submit a claim and required information
- **dispute_resolution.md** - How to opt out or object to the settlement

These demonstrate both simple extraction and synthesis tasks. Adapt them for your specific document types and information needs.

## Output

All results are saved to a timestamped directory with files named:
- `payment_terms_result.md`
- `key_dates_result.md`
- `parties_and_roles_result.md`
- `confidentiality_result.md`
- `release_and_liability_result.md`
- `compliance_obligations_result.md`
- `dispute_resolution_result.md`

## Example Run

```bash
$ ./analyze_settlement.sh contract.md

===================================
Settlement Agreement Analysis
===================================
Input file: contract.md
Output directory: results_2025-10-22_14-30-45
Starting parallel analysis...

→ Starting analysis: Settlement Amount & Distribution
→ Starting analysis: Key Dates
→ Starting analysis: Eligibility Criteria
→ Starting analysis: Case Summary
→ Starting analysis: Released Claims
→ Starting analysis: Claim Process
→ Starting analysis: Opt-Out Rights

All analyses launched. Waiting for completion...
```

## Customization

To add new analysis types:

1. Create a new prompt file in `prompts/` directory with a focused extraction question
2. Add an entry to the `analyses` array in `analyze_settlement.sh` (format: "prompt_name:Description")
3. Run the script - it will automatically include the new analysis

## Requirements

- [Codex CLI](https://developers.openai.com/codex/cli) installed and authenticated
- Bash shell (compatible with bash 3.2+, works on macOS and Linux)
- A markdown-formatted document to analyze (use [MarkItDown](https://github.com/microsoft/markitdown) to convert PDFs, Word docs, Excel sheets, and other office formats to markdown)

## Use Cases

This pattern works well for:
- **Contracts & legal documents** - Extract parties, terms, dates, obligations
- **Financial reports** - Extract KPIs, figures, trends from different sections
- **Meeting notes** - Extract action items, decisions, attendees, follow-ups
- **Research papers** - Extract methodology, findings, datasets, conclusions
- **Technical specs** - Extract requirements, dependencies, timelines, constraints

The key is defining focused extraction questions in each prompt file.
