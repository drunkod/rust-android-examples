#!/bin/bash

# Function to make curl requests
make_request() {
    curl -X POST -H "Content-Type: application/json" -d "$1" http://192.168.3.40:8080/command
}

# Create Mixer
# make_request '{"createmixer": {"id": "channel-1", "config": {"width": 1280, "height": 720, "sample-rate": 44100}}}'

# Create Local Playback Destination
make_request '{"createdestination": {"id": "centricular-output", "family": "LocalPlayback"}}'

# # Connect Mixer to Playback Destination
# make_request '{"connect": {"link_id": "channel-1", "src_id": "channel-1", "sink_id": "centricular-output"}}'

# # Start Playback Destination
# make_request '{"start": {"id": "centricular-output"}}'

# # Start Mixer
# make_request '{"start": {"id": "channel-1"}}'

# # Schedule Source Slot
# source_slot=$(make_request '{"schedule_source": {"uri": "'"$source_uri"'", "id": "source_slot", "node_id": "channel-1", "cue_time": 0, "end_time": 10, "slot_config": {"video::zorder": 2, "video::alpha": 1.0, "audio::volume": 1.0, "video::width": 1280, "video::height": 720, "video::sizing-policy": "keep-aspect-ratio"}}}')

# # Schedule Destination Slot
# dest_slot=$(make_request '{"schedule_source": {"uri": "'"$dest_uri"'", "id": "dest_slot", "node_id": "channel-1", "cue_time": 5, "slot_config": {"video::zorder": 1, "video::alpha": 0.0, "audio::volume": 0.0, "video::width": 1280, "video::height": 720, "video::sizing-policy": "keep-aspect-ratio"}}}')

# # Add Control Points
# make_request '{"addcontrolpoint": {"id": "control-1", "slot_id": "'"$source_slot"'", "param_name": "video::alpha", "cue_time": 5, "value": 1.0, "interpolate": false}}'
# make_request '{"addcontrolpoint": {"id": "control-2", "slot_id": "'"$source_slot"'", "param_name": "video::alpha", "cue_time": 10, "value": 0.0}}'

# make_request '{"addcontrolpoint": {"id": "control-1", "slot_id": "'"$dest_slot"'", "param_name": "video::alpha", "cue_time": 5, "value": 0.0, "interpolate": false}}'
# make_request '{"addcontrolpoint": {"id": "control-2", "slot_id": "'"$dest_slot"'", "param_name": "video::alpha", "cue_time": 10, "value": 1.0}}'

# make_request '{"addcontrolpoint": {"id": "control-1", "slot_id": "'"$source_slot"'", "param_name": "audio::volume", "cue_time": 5, "value": 1.0, "interpolate": false}}'
# make_request '{"addcontrolpoint": {"id": "control-2", "slot_id": "'"$source_slot"'", "param_name": "audio::volume", "cue_time": 10, "value": 0.0}}'

# make_request '{"addcontrolpoint": {"id": "control-1", "slot_id": "'"$dest_slot"'", "param_name": "audio::volume", "cue_time": 5, "value": 0.0, "interpolate": false}}'
# make_request '{"addcontrolpoint": {"id": "control-2", "slot_id": "'"$dest_slot"'", "param_name": "audio::volume", "cue_time": 10, "value": 1.0}}'

# # Sleep for 2 seconds
# sleep 2

# # # Get Information
# make_request '{"getinfo": {}}'
