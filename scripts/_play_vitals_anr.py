"""Query Play Developer Reporting for PixReveal vc31 ANR rate + top clusters."""
import sys, io, json
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
from google.oauth2 import service_account
from googleapiclient.discovery import build

SA = r'C:\Users\ickmk\desktop\projeler-claude\galeripost\google-service-account.json'
PKG = 'com.cytbilisim.pixreveal'
APP = f'apps/{PKG}'

SCOPES_REPORTING = ['https://www.googleapis.com/auth/playdeveloperreporting']

def main():
    creds = service_account.Credentials.from_service_account_file(SA, scopes=SCOPES_REPORTING)
    svc = build('playdeveloperreporting', 'v1beta1', credentials=creds, cache_discovery=False)

    # 1) ANR rate metric last 7 days
    print("=== ANR rate (metric set) ===")
    try:
        metric = f'{APP}/anrRateMetricSet'
        req_body = {
            'timelineSpec': {
                'aggregationPeriod': 'DAILY',
                'startTime': {'year': 2026, 'month': 11, 'day': 13, 'timeZone': {'id': 'Europe/Istanbul'}},
                'endTime':   {'year': 2026, 'month': 11, 'day': 20, 'timeZone': {'id': 'Europe/Istanbul'}},
            },
            'metrics': ['anrRate', 'userPerceivedAnrRate', 'distinctUsers'],
            'dimensions': ['versionCode'],
            'pageSize': 1000,
        }
        res = svc.vitals().anrrate().query(name=metric, body=req_body).execute()
        rows = res.get('rows', [])
        print(f"rows: {len(rows)}")
        for r in rows[:50]:
            dims = {d['dimension']: d.get('int64Value', d.get('stringValue')) for d in r.get('dimensions', [])}
            mets = {m['metric']: m.get('decimalValue', {}).get('value') for m in r.get('metrics', [])}
            print(f"  vc={dims.get('versionCode')} startTime={r.get('startTime')} anrRate={mets.get('anrRate')} userPerceived={mets.get('userPerceivedAnrRate')} users={mets.get('distinctUsers')}")
    except Exception as e:
        print(f"ANR rate ERROR: {e}")

    # 2) ANR issue clusters
    print("\n=== ANR issues ===")
    try:
        parent = f'{APP}/errorIssues'
        # filter ANR only, last 7 days
        req = svc.vitals().errors().issues().search(
            parent=APP,
            filter='errorIssueType = ANR AND versionCode = 31',
            pageSize=10,
            orderBy='errorReportCount desc',
            interval_startTime_year=2026, interval_startTime_month=11, interval_startTime_day=13,
            interval_startTime_timeZone_id='Europe/Istanbul',
            interval_endTime_year=2026, interval_endTime_month=11, interval_endTime_day=20,
            interval_endTime_timeZone_id='Europe/Istanbul',
        ).execute()
        issues = req.get('errorIssues', [])
        print(f"issues: {len(issues)}")
        for i, iss in enumerate(issues[:5]):
            print(f"\n--- issue #{i+1} ---")
            print(f"  name: {iss.get('name')}")
            print(f"  type: {iss.get('type')}")
            print(f"  cause: {iss.get('cause')}")
            print(f"  location: {iss.get('location')}")
            print(f"  errorReportCount: {iss.get('errorReportCount')}")
            print(f"  distinctUsers: {iss.get('distinctUsers')}")
            print(f"  firstAppVersion: {iss.get('firstAppVersion')}")
            print(f"  lastAppVersion: {iss.get('lastAppVersion')}")
            print(f"  sampleErrorReports: {iss.get('sampleErrorReports', [])[:3]}")
    except Exception as e:
        print(f"ANR issues ERROR: {e}")

    # 3) Fetch sample reports for top issue
    print("\n=== ANR sample reports (top issue) ===")
    try:
        req = svc.vitals().errors().reports().search(
            parent=APP,
            filter='errorIssueType = ANR AND versionCode = 31',
            pageSize=3,
            interval_startTime_year=2026, interval_startTime_month=11, interval_startTime_day=13,
            interval_startTime_timeZone_id='Europe/Istanbul',
            interval_endTime_year=2026, interval_endTime_month=11, interval_endTime_day=20,
            interval_endTime_timeZone_id='Europe/Istanbul',
        ).execute()
        reports = req.get('errorReports', [])
        print(f"reports: {len(reports)}")
        for r in reports[:3]:
            print(f"\n--- report ---")
            print(f"  name: {r.get('name')}")
            print(f"  type: {r.get('type')}")
            print(f"  deviceModel: {r.get('deviceModel')}")
            print(f"  osVersion: {r.get('osVersion')}")
            print(f"  appVersion: {r.get('appVersion')}")
            print(f"  eventTime: {r.get('eventTime')}")
            rt = r.get('reportText', '')
            print(f"  reportText[:2000]:\n{rt[:2000]}")
    except Exception as e:
        print(f"ANR reports ERROR: {e}")

if __name__ == '__main__':
    main()
