import os, winreg, requests

def get_reg(name):
    with winreg.OpenKey(winreg.HKEY_CURRENT_USER, "Environment") as k:
        return winreg.QueryValueEx(k, name)[0]

token = get_reg("CODEMAGIC_API_TOKEN")
print(f"Token: ...{token[-8:]}")

resp = requests.post(
    "https://api.codemagic.io/builds",
    headers={"x-auth-token": token, "Content-Type": "application/json"},
    json={
        "appId": "6a3fbf292c74e293a9d1fe1e",
        "workflowId": "ios-release",
        "branch": "main"
    },
    timeout=30
)
print(f"Status: {resp.status_code}")
print(resp.json())
