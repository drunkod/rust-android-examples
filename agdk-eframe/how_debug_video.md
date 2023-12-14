Run udp, when 192.168.3.62 - client pc

create_udp_local_playback_destination('centricular-output', '192.168.3.62')

Open in vlc player:

udp://@:5005



Open a UDP socket connection to 127.0.0.1:5005 using netcat:

nc -u 127.0.0.1 5005

In another terminal, start a UDP server listening on port 5005:

nc -ul 5005
In the client netcat, type some text and hit enter to send a UDP packet:

Hello