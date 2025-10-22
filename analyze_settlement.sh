#!/bin/bash

# Settlement Agreement Analysis Demo
# Runs multiple codex instances in parallel, each extracting different information

set -e

# Configuration
SETTLEMENT_FILE="${1:-settlement_agreement.md}"
PROMPTS_DIR="prompts"

# Check if settlement file exists
if [ ! -f "$SETTLEMENT_FILE" ]; then
    echo "Error: Settlement file '$SETTLEMENT_FILE' not found"
    echo "Usage: $0 [settlement_file.md]"
    exit 1
fi

# Create datestamped output directory
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="results_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

echo "==================================="
echo "Settlement Agreement Analysis"
echo "==================================="
echo "Input file: $SETTLEMENT_FILE"
echo "Output directory: $OUTPUT_DIR"
echo "Starting parallel analysis..."
echo ""

# Array to store background process PIDs
pids=()

# Define the analyses to run (format: "prompt_name:Description")
analyses=(
    "payment_terms:Payment Terms"
    "key_dates:Key Dates & Deadlines"
    "parties_and_roles:Parties & Roles"
    "confidentiality:Confidentiality"
    "release_and_liability:Release & Liability"
    "compliance_obligations:Compliance Obligations"
    "dispute_resolution:Dispute Resolution"
)

# Launch parallel codex instances
for analysis in "${analyses[@]}"; do
    # Split on colon
    prompt_name="${analysis%%:*}"
    description="${analysis#*:}"

    prompt_file="${PROMPTS_DIR}/${prompt_name}.md"
    output_file="${OUTPUT_DIR}/${prompt_name}_result.md"

    echo "→ Starting analysis: $description"

    # Run codex in background
    (
        echo "Analyze $SETTLEMENT_FILE" | \
        codex -c "experimental_instructions_file=\"$prompt_file\"" \
        exec --skip-git-repo-check - -o "$output_file" 2>&1 | \
        sed "s/^/[$prompt_name] /" || echo "[$prompt_name] Error occurred"
    ) &

    pids+=($!)
done

echo ""
echo "All analyses launched. Waiting for completion..."
echo ""

# Wait for all background jobs and track completion
completed=0
total=${#pids[@]}

for pid in "${pids[@]}"; do
    if wait "$pid"; then
        ((completed++))
        echo "✓ Analysis completed ($completed/$total)"
    else
        echo "✗ Analysis failed (PID $pid)"
    fi
done

echo ""
echo "==================================="
echo "Analysis Complete!"
echo "==================================="
echo "Results saved to: $OUTPUT_DIR/"
echo ""
echo "Generated files:"
ls -lh "$OUTPUT_DIR"
echo ""
echo "To view results:"
echo "  cat $OUTPUT_DIR/*.md"
echo ""
