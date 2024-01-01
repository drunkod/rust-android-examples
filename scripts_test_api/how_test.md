# How to test api


1. Run app in debug mode

`
agdk-eframe/build_and_copy.sh
`

2. Test api

`
curl -X POST -H "Content-Type: application/json" -d '{"getinfo":{}}' http://192.168.3.40:8080/command
`

`
python scripts_test_api/crossfade.py source_uri, dest_uri

`