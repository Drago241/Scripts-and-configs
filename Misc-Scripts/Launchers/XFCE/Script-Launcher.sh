#!/bin/bash

# List your scripts here
SCRIPTS=(
    ""
    ""
    ""
)

run_script() {
    local script_path="$1"
    if [[ -f "$script_path" && -x "$script_path" ]]; then
        echo "Launching '$script_path'..."
        # The '&' at the end runs it in the background
        "$script_path" & 
    else
        echo "Error: '$script_path' is missing or not executable."
    fi
}

for script in "${SCRIPTS[@]}"; do
    run_script "$script"
done

# Optional: Disown processes so they keep running if this parent script closes
disown -a
echo "All scripts triggered."
