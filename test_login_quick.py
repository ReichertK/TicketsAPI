#!/usr/bin/env python3
import requests
import sys
import time

# Wait for API to be ready
time.sleep(5)

print("Testing login...")
try:
    resp = requests.post(
        'http://localhost:5000/api/v1/Auth/login',
        json={'Usuario': 'admin', 'Contraseña': 'changeme'},
        verify=False,
        timeout=10
    )
    print(f"Status: {resp.status_code}")
    print(f"Response: {resp.text[:500]}")
    
    if resp.status_code == 200:
        data = resp.json()
        print(f"Login OK, token obtained: {len(data.get('datos', {}).get('token', ''))} chars")
        sys.exit(0)
    else:
        print(f"Login failed with status {resp.status_code}")
        sys.exit(1)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
