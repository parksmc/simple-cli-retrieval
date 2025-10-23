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
LOGS_DIR="${OUTPUT_DIR}/logs"
mkdir -p "$OUTPUT_DIR" "$LOGS_DIR"

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
    "payment_terms:Settlement Amount & Distribution"
    "key_dates:Key Dates"
    "parties_and_roles:Eligibility Criteria"
    "confidentiality:Case Summary"
    "release_and_liability:Released Claims"
    "compliance_obligations:Claim Process"
    "dispute_resolution:Opt-Out Rights"
)

# Launch parallel codex instances
for analysis in "${analyses[@]}"; do
    # Split on colon
    prompt_name="${analysis%%:*}"
    description="${analysis#*:}"

    prompt_file="${PROMPTS_DIR}/${prompt_name}.md"
    output_file="${OUTPUT_DIR}/${prompt_name}_result.md"
    log_file="${LOGS_DIR}/${prompt_name}.log"

    echo "→ Starting analysis: $description"

    # Run codex in background with full logging
    (
        {
            echo "====================================" >> "$log_file"
            echo "Analysis: $description" >> "$log_file"
            echo "Prompt: $prompt_name" >> "$log_file"
            echo "Started: $(date)" >> "$log_file"
            echo "====================================" >> "$log_file"
            echo "" >> "$log_file"

            echo "Analyze $SETTLEMENT_FILE" | \
            codex -c "experimental_instructions_file=\"$prompt_file\"" \
            exec --skip-git-repo-check - -o "$output_file" 2>&1 | \
            tee -a "$log_file" | \
            sed "s/^/[$prompt_name] /"

            echo "" >> "$log_file"
            echo "====================================" >> "$log_file"
            echo "Completed: $(date)" >> "$log_file"
            echo "====================================" >> "$log_file"
        } || {
            echo "[$prompt_name] Error occurred"
            echo "ERROR: Analysis failed at $(date)" >> "$log_file"
        }
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

# Extract and display token usage summary from logs
echo "==================================="
echo "Token Usage Summary"
echo "==================================="
echo ""

total_input_tokens=0
total_output_tokens=0

for log_file in "$LOGS_DIR"/*.log; do
    if [ -f "$log_file" ]; then
        prompt_name=$(basename "$log_file" .log)

        # Extract token counts (adjust patterns based on actual codex output format)
        input_tokens=$(grep -oE "Input tokens?:? [0-9,]+" "$log_file" | grep -oE "[0-9,]+" | tail -1 | tr -d ',')
        output_tokens=$(grep -oE "Output tokens?:? [0-9,]+" "$log_file" | grep -oE "[0-9,]+" | tail -1 | tr -d ',')

        if [ -n "$input_tokens" ] && [ -n "$output_tokens" ]; then
            echo "[$prompt_name]"
            echo "  Input:  ${input_tokens:-0} tokens"
            echo "  Output: ${output_tokens:-0} tokens"
            echo ""

            total_input_tokens=$((total_input_tokens + ${input_tokens:-0}))
            total_output_tokens=$((total_output_tokens + ${output_tokens:-0}))
        fi
    fi
done

if [ $total_input_tokens -gt 0 ] || [ $total_output_tokens -gt 0 ]; then
    echo "-----------------------------------"
    echo "Total Input:  $total_input_tokens tokens"
    echo "Total Output: $total_output_tokens tokens"
else
    echo "Token usage information not found in logs."
    echo "Check individual log files for raw output."
fi

echo ""
echo "==================================="
echo ""
echo "To view results:"
echo "  cat $OUTPUT_DIR/*.md"
echo ""
echo "To view detailed logs:"
echo "  cat $LOGS_DIR/*.log"
echo ""
