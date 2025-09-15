#!/bin/bash

# Fix imports in node files
for file in agdk-eframe/src/domain/nodes/{mixer,source,video_generator,destination}.rs; do
    # Replace super::node:: with super::
    sed -i 's/use super::node::/use super::/g' "$file"

    # Add ConsumerMessage if needed
    if grep -q "ConsumerMessage" "$file" && ! grep -q "use super::.*ConsumerMessage" "$file"; then
        sed -i '/use super::{/s/$/ConsumerMessage, /' "$file"
    fi
done

# Ensure destination.rs has proper imports
if ! grep -q "use super::.*ConsumerMessage" agdk-eframe/src/domain/nodes/destination.rs; then
    echo "use super::ConsumerMessage;" >> agdk-eframe/src/domain/nodes/destination.rs
fi

# Fix ErrorMessage usage
find agdk-eframe/src -name "*.rs" -exec sed -i 's/ErrorMessage(/ErrorMessage { message: /g' {} \;
find agdk-eframe/src -name "*.rs" -exec sed -i 's/ErrorMessage { message: (\([^)]*\))/ErrorMessage { message: \1.to_string() }/g' {} \;

echo "Fixes applied."
