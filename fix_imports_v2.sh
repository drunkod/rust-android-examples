#!/bin/bash

# Fix module declarations
find agdk-eframe/src -name "mod.rs" -exec sed -i '1d' {} \;

# Fix use statements in domain layer
find agdk-eframe/src/domain -name "*.rs" | while read -r file; do
    # Remove duplicate imports
    awk '!seen[$0]++' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

# Fix shared module imports
sed -i 's/use crate::shared::/use crate::shared::{/g' agdk-eframe/src/shared/mod.rs
