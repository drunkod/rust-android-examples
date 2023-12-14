import argparse
import time

from node import get_info, create_mixer, create_local_playback_destination, remove_node, create_rtmp_destination, start_node, connect, create_videogenerator, schedule_source, later, create_udp_local_playback_destination, add_control_point, schedule_video_source

if __name__ == '__main__':
    parser = argparse.ArgumentParser('crossfade')

    parser.add_argument('source_uri')
    parser.add_argument('dest_uri')

    args = parser.parse_args()

    source_uri = args.source_uri
    dest_uri = args.dest_uri
    # for stop node call remove
    # remove_node('channel-1')
    # remove_node('centricular-output')
    create_mixer('channel-1', config={
        'width': 1280,
        'height': 720,
        'sample-rate': 44100,
    },
    disable_video=False)
    # create_videogenerator('channel-1')
    # # rtmp://ovsu.mycdn.me/input/7165604277137_5863688964753_ntftfa2i4m
    # # rtmps://dc4-1.rtmp.t.me/s/4018499832:im0paW2eEZTVdPI_JN2VaQ
    # # rtmp://rtmp.facecast.io/live/test_1803
    # 192.168.3.40

    create_udp_local_playback_destination('centricular-output', '192.168.3.62')
    # create_rtmp_destination('centricular-output', 'rtmp://ovsu.mycdn.me/input/7165604277137_5863688964753_ntftfa2i4m')
    # # create_local_playback_destination('centricular-output', disable_video=True)
    
    connect('channel-1', 'centricular-output', disable_video=False)
    start_node('centricular-output')
    start_node('channel-1')
    # start_node('centricular-output')

    time.sleep(2)
    source_uri='http://192.168.3.40:8888/storage/emulated/0/Download/videoshare/5294144621210.mp4'
    dest_uri='http://192.168.3.40:8888/storage/emulated/0/Download/videoshare/5294144621210.mp4'
    # link_id = schedule_source('http://192.168.3.40:8888/storage/emulated/0/Download/videoshare/5294144621210.mp4', 'bbb', 'channel-1', later(15), slot_config={
    #             'video::zorder': 1,
    #             'video::alpha': 1.0,
    #             'audio::volume': 1.0,
    #             'video::width': 1280,
    #             'video::height': 720,
    #             'video::sizing-policy': 'keep-aspect-ratio',
    #         })
    # time.sleep(2)
    # start_node('centricular-output')
    # get_info('bbb')
    source_slot = schedule_video_source('source_slot', 'channel-1', later(0), later(10),
            slot_config={
                'video::zorder': 2,
                'video::alpha': 1.0,
                'audio::volume': 1.0,
                'video::width': 1280,
                'video::height': 720,
                'video::sizing-policy': 'keep-aspect-ratio',
            })

    dest_slot = schedule_video_source('dest_slot', 'channel-1', later(5),
            slot_config={
                'video::zorder': 1,
                'video::alpha': 0.0,
                'audio::volume': 0.0,
                'video::width': 1280,
                'video::height': 720,
                'video::sizing-policy': 'keep-aspect-ratio',
            })
    get_info('source_slot')
    get_info('dest_slot')
    # add_control_point('control-1', source_slot, 'video::alpha', later(5), 1.0, interpolate=False)
    # add_control_point('control-2', source_slot, 'video::alpha', later(10), 0.0)

    # add_control_point('control-1', dest_slot, 'video::alpha', later(5), 0.0, interpolate=False)
    # add_control_point('control-2', dest_slot, 'video::alpha', later(10), 1.0)

    # add_control_point('control-1', source_slot, 'audio::volume', later(5), 1.0, interpolate=False)
    # add_control_point('control-2', source_slot, 'audio::volume', later(10), 0.0)

    # add_control_point('control-1', dest_slot, 'audio::volume', later(5), 0.0, interpolate=False)
    # add_control_point('control-2', dest_slot, 'audio::volume', later(10), 1.0)

    

    time.sleep(2)

    get_info()


    # test     get_info()
    # curl -X POST -H "Content-Type: application/json" -d '{"getinfo":{}}' http://192.168.3.40:8080/command

    # test from cli 
    # python scripts/crossfade.py source_uri, dest_uri