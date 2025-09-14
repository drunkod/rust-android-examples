#!/bin/bash

find src -name "*.rs" | while read -r file; do
    # Add use statements for common crates
    if grep -q "actix" "$file"; then
        sed -i '1i use actix::prelude::*;' "$file"
    fi
    if grep -q "anyhow" "$file"; then
        sed -i '1i use anyhow::{anyhow, Error};' "$file"
    fi
    if grep -q "gst" "$file"; then
        sed -i '1i use gst::prelude::*;' "$file"
    fi
    if grep -q "chrono" "$file"; then
        sed -i '1i use chrono::{DateTime, Utc};' "$file"
    fi
    if grep -q "tracing" "$file"; then
        sed -i '1i use tracing::{debug, error, instrument, trace};' "$file"
    fi
    if grep -q "serde" "$file"; then
        sed -i '1i use serde::{Deserialize, Serialize};' "$file"
    fi
    if grep -q "uuid" "$file"; then
        sed -i '1i use uuid;' "$file"
    fi
    if grep -q "structopt" "$file"; then
        sed -i '1i use structopt::StructOpt;' "$file"
    fi
    if grep -q "futures" "$file"; then
        sed -i '1i use futures::prelude::*;' "$file"
    fi

    # Fix paths
    sed -i 's/crate::utils/crate::shared/g' "$file"
    sed -i 's/crate::nodes/crate::domain::nodes/g' "$file"
done
