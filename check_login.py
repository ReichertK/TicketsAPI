#!/usr/bin/env python3
import requests
import json
import urllib3

urllib3.disable_warnings()

resp = requests.post('https://localhost:5001/api/v1/Auth/Login', 
    json={'Usuario': 'admin', 'Contraseña': 'changeme'},
    verify=False)

print(f'Status: {resp.status_code}')
print(f'Content-Type: {resp.headers.get("Content-Type")}')
print(f'Response:\n{json.dumps(resp.json(), indent=2)}')
