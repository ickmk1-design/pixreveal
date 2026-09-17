import winreg, requests

def get_reg(name):
    with winreg.OpenKey(winreg.HKEY_CURRENT_USER, "Environment") as k:
        return winreg.QueryValueEx(k, name)[0]

t = get_reg("CODEMAGIC_API_TOKEN")
r = requests.get("https://api.codemagic.io/builds/6a8fd62978d15997b82501d5",
                 headers={"x-auth-token": t}, timeout=30)
d = r.json().get("build", {})
print(f"Status: {d.get('status')}")
print(f"Created: {d.get('createdAt')}")
print("URL: https://codemagic.io/app/6a3fbf292c74e293a9d1fe1e/build/6a8fd62978d15997b82501d5")
