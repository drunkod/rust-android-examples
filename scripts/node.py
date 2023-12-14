import datetime
import requests
import uuid
import os
import json

NOW = datetime.datetime.utcnow()
HERE = os.path.dirname(os.path.abspath(__file__))
# SERVER = 'http://192.168.43.53:8080/command'
SERVER = 'http://192.168.3.40:8080/command'
# 192.168.219.234
# SERVER = 'http://192.168.219.234:8080/command'  

def send_request(action, params):
    try:
        headers = {'Content-Type': 'application/json'}
        data = json.dumps({action: params})
        response = requests.post(SERVER, headers=headers, data=data)
        
        if response.status_code == 200:
            if response.text:
                print(response.text)
            else:
                print("No data returned from server.")
        else:
            raise Exception("Invalid response: %s" % response.status_code)

    except Exception as e:
        print(e)

def create_videogenerator(id_):
    action = 'createvideogenerator'

    params = {"id": id_}

    send_request(action, params)

def get_info(id_=None):
    action = 'getinfo'

    if id_ is not None:
        params = {"id": id_}
    else:
        params = {}

    send_request(action, params)

def remove_node(id_):
    action = 'remove'
    params = {"id": id_}
    send_request(action, params)       

def create_source(id_, uri, disable_audio=False, disable_video=False):
    action = 'createsource'
    params = {
        'id': id_,
        'uri': uri,
    }

    if disable_audio:
        params['audio'] = False    
    if disable_video:
        params['video'] = False
    send_request(action, params)

def create_video_generator(id_):
    action = 'createvideogenerator'
    params = {
        'id': id_,
    }
    send_request(action, params)    

def create_local_file_destination(id_, basename, max_size_time=None, disable_audio=False, disable_video=False):
    action = 'create local file destination'
    params = {"id": id_, "basename": basename, "max_size_time": max_size_time, "disable_audio": disable_audio, "disable_video": disable_video}
    send_request(action, params)

def create_local_playback_destination(id_, disable_audio=False, disable_video=False):
    action = 'createdestination'
    params = {
        'id': id_,
        'family': 'LocalPlayback',
    }

    if disable_audio:
        params['audio'] = False    
    if disable_video:
        params['video'] = False

    send_request(action, params)
# Example usage:
# create_local_playback_destination('your_destination_id', disable_audio=True)
# create_local_playback_destination('your_destination_id', disable_video=True)
# create_local_playback_destination('your_destination_id', disable_audio=True, disable_video=True)
# create_local_playback_destination('your_destination_id')  # No disable options

def create_mixer(id_, config=None, disable_audio=False, disable_video=False):
    action = 'createmixer'
    params = {'id': id_,
    'config': config,}
    print(config)
    if config is not None:
        params.update(config)

    if disable_audio:
        params['audio'] = False    
    if disable_video:
        params['video'] = False

    send_request(action, params)
# Example usage:
# create_mixer('your_mixer_id', disable_audio=True)
# create_mixer('your_mixer_id', config={'param1': 'value1', 'param2': 'value2'})
# create_mixer('your_mixer_id', disable_video=True)
# create_mixer('your_mixer_id', config={'param1': 'value1', 'param2': 'value2'}, disable_audio=True, disable_video=True)
# create_mixer('your_mixer_id')  # No disable or config options    

def create_rtmp_destination(id_, uri, disable_audio=False, disable_video=False):
    base_url = 'http://'  # Replace with the actual base URL of your server

    action = 'createdestination'
    params = {
        'id': id_,
        'family': {'Rtmp': {'uri': uri}},
    }
    if disable_audio:
        params['audio'] = False    
    if disable_video:
        params['video'] = False

    send_request(action, params)

# Example usage:
# create_rtmp_destination('your_destination_id', 'your_uri', disable_audio=True)
# create_rtmp_destination('your_destination_id', 'your_uri', disable_video=True)
# create_rtmp_destination('your_destination_id', 'your_uri', disable_audio=True, disable_video=True)
# create_rtmp_destination('your_destination_id', 'your_uri')  # No disable options

def start_node(id_, cue_time=None, end_time=None):

    action = 'start'
    params = {'id': id_}

    if cue_time is not None:
        params['cue_time'] = cue_time.isoformat() + 'Z'

    if end_time is not None:
        params['end_time'] = end_time.isoformat() + 'Z'

    send_request(action, params)

# Example usage:
# start_node('your_node_id', cue_time=datetime.datetime(2023, 1, 1, 12, 0, 0), end_time=datetime.datetime(2023, 1, 1, 13, 0, 0))
# start_node('your_node_id')  # To start immediately    

def connect(src_id, sink_id, config=None, disable_audio=False, disable_video=False):

    link_id = f'{src_id}->{sink_id}_{str(uuid.uuid4())}'
    action = 'connect'

    params = {
        'link_id': link_id,
        'src_id': src_id,
        'sink_id': sink_id,
        'config': config,
    }

    if disable_audio:
        params['audio'] = False    
    if disable_video:
        params['video'] = False

    if config is not None:
        params.update(config)

    send_request(action, params)

    return link_id

# Example usage:
# connect('source_node_id', 'sink_node_id', disable_audio=True)
# connect('source_node_id', 'sink_node_id', config={'param1': 'value1', 'param2': 'value2'})
# connect('source_node_id', 'sink_node_id', disable_video=True)
# connect('source_node_id', 'sink_node_id', config={'param1': 'value1', 'param2': 'value2'}, disable_audio=True, disable_video=True)
# connect('source_node_id', 'sink_node_id')  # No config or disable options

def create_udp_local_playback_destination(id_, host='localhost', disable_audio=False, disable_video=False):
    action = 'createdestination'
    params = {
        'id': id_,
        'family': {'Udp': {'host': host}},
    }

    if disable_audio:
        params['audio'] = False    
    if disable_video:
        params['video'] = False

    send_request(action, params)

def schedule_source(uri, src_id, dst_id, cue_time=None, end_time=None, slot_config=None, connect_audio=True, connect_video=True, disable_audio=False, disable_video=False):
    create_source(src_id, uri, disable_audio=disable_audio, disable_video=disable_video)
    link_id = connect(src_id, dst_id, config=slot_config, disable_audio=not connect_audio, disable_video=not connect_video)
    start_node(src_id, cue_time, end_time)
    return link_id

def schedule_video_source(src_id, dst_id, cue_time=None, end_time=None, slot_config=None, connect_audio=True, connect_video=True, disable_audio=False, disable_video=False):
    create_video_generator(src_id)
    link_id = connect(src_id, dst_id, config=slot_config, disable_audio=not connect_audio, disable_video=not connect_video)
    start_node(src_id, cue_time, end_time)
    return link_id


def later(delay):
    return NOW + datetime.timedelta(seconds=delay)

def add_control_point(controller_id, controllee_id, prop, time, value, interpolate=True):
    value = str(value)

    action = 'addcontrolpoint'

    if interpolate:
        mode = 'interpolate'
    else:
        mode = 'set'

    params = {
        'controllee_id': controllee_id,
        'property': prop,
        'control_point': {
                        'id': controller_id,
                        'time': time.isoformat() + 'Z',
                        'value': value,
                        'mode': mode,},
    }

    send_request(action, params) 

def start_node(id_, cue_time=None, end_time=None):

    action = 'start'
    params = {'id': id_}

    if cue_time is not None:
        params['cue_time'] = cue_time.isoformat() + 'Z'

    if end_time is not None:
        params['end_time'] = end_time.isoformat() + 'Z'

    send_request(action, params)        