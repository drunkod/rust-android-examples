#!/bin/bash

# Fix tracing macros
find agdk-eframe/src -name "*.rs" -exec sed -i 's/fields(pad = pad\.name())/fields(pad = %pad.name())/g' {} \;
find agdk-eframe/src -name "*.rs" -exec sed -i 's/fields(pad = \([^)]*\)\.name())/fields(pad = %\1.name())/g' {} \;
find agdk-eframe/src -name "*.rs" -exec sed -i 's/trace!(obj = \([^,]*\)\.name()/trace!(obj = %\1.name()/g' {} \;
find agdk-eframe/src -name "*.rs" -exec sed -i 's/debug!(appsink = \([^,]*\)\.name()/debug!(appsink = %\1.name()/g' {} \;

# Fix pattern matching in mixer.rs
sed -i 's/if let Some(Some(slot)) = slot {/if let Some(slot) = slot.as_ref() {/g' agdk-eframe/src/domain/nodes/mixer.rs

# Fix StopMessage handler return type
sed -i '/impl Handler<StopMessage> for Source {/,/^}/ s/type Result = ();/type Result = Result<(), Error>;/' agdk-eframe/src/domain/nodes/source.rs

echo "Applied automatic fixes. Manual fixes still needed for:"
echo "1. Add missing methods to Mixer"
echo "2. Update NodeManager handlers"
echo "3. Fix Schedulable trait bounds"
