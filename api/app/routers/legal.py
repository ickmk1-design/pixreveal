from fastapi import APIRouter
from fastapi.responses import HTMLResponse

router = APIRouter(tags=["legal"])

PRIVACY_POLICY = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PixReveal - Privacy Policy</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; color: #e0e0e0; background: #0a0a1a; line-height: 1.6; }
  h1 { color: #ff00ff; } h2 { color: #00ffff; } h3 { color: #00ff00; }
  a { color: #ff00ff; }
</style>
</head>
<body>
<h1>Privacy Policy</h1>
<p><strong>Effective Date:</strong> April 8, 2026<br>
<strong>Last Updated:</strong> April 8, 2026</p>

<p>PixReveal ("the App") is developed and operated by <strong>CYT Bilişim Hizmetleri</strong>, a company based in Turkey. This Privacy Policy explains how we collect, use, and protect your information.</p>

<h2>1. Information We Collect</h2>

<h3>1.1 Account Information</h3>
<p>When you create an account, we may collect:</p>
<ul>
<li>Display name</li>
<li>Email address (if you sign in with email, Google, or Apple)</li>
<li>Authentication provider identifiers (Firebase UID)</li>
</ul>
<p>If you use Guest Mode (Anonymous Auth), we only store a random identifier with no personal information.</p>

<h3>1.2 Game Data</h3>
<ul>
<li>Level progress and scores</li>
<li>Token balance and purchase history</li>
<li>Achievement and leaderboard data</li>
</ul>

<h3>1.3 Automatically Collected Data</h3>
<ul>
<li>Device type, OS version</li>
<li>App usage analytics (via Firebase Analytics)</li>
<li>Crash reports</li>
</ul>

<h2>2. How We Use Your Information</h2>
<ul>
<li>To provide and improve the game experience</li>
<li>To manage your account and game progress</li>
<li>To process in-app purchases (via RevenueCat)</li>
<li>To display advertisements (via Google AdMob)</li>
<li>To send push notifications (via Firebase Cloud Messaging), if you opt in</li>
<li>To maintain leaderboards and social features</li>
</ul>

<h2>3. Third-Party Services</h2>
<p>We use the following third-party services that may collect data:</p>
<ul>
<li><strong>Firebase</strong> (Google) — Authentication, Analytics, Cloud Messaging, Crashlytics</li>
<li><strong>Google AdMob</strong> — Advertising (ad identifiers, device info)</li>
<li><strong>RevenueCat</strong> — In-app purchase management</li>
</ul>
<p>Each service has its own privacy policy. We encourage you to review them.</p>

<h2>4. Data Sharing</h2>
<p>We do <strong>not</strong> sell your personal data. We share data only with:</p>
<ul>
<li>Third-party service providers listed above, as necessary to operate the App</li>
<li>Law enforcement, if required by applicable law</li>
</ul>

<h2>5. Children's Privacy</h2>
<p>PixReveal is intended for users aged <strong>13 and older</strong>. We do not knowingly collect personal information from children under 13. If you believe a child under 13 has provided us with personal information, please contact us at <a href="mailto:info@cytbilisim.com">info@cytbilisim.com</a> and we will delete it promptly.</p>

<h2>6. Data Retention and Deletion</h2>
<p>We retain your data as long as your account is active. You may request deletion of your account and all associated data at any time through:</p>
<ul>
<li>The "Delete Account" option in Settings</li>
<li>Emailing us at <a href="mailto:info@cytbilisim.com">info@cytbilisim.com</a></li>
</ul>
<p>Upon deletion, all personal data and game progress will be permanently removed within 30 days.</p>

<h2>7. Your Rights (GDPR / KVKK)</h2>
<p>Under the EU General Data Protection Regulation (GDPR) and Turkey's Personal Data Protection Law (KVKK, Law No. 6698), you have the right to:</p>
<ul>
<li>Access your personal data</li>
<li>Rectify inaccurate data</li>
<li>Request erasure of your data</li>
<li>Object to or restrict processing</li>
<li>Data portability</li>
<li>Withdraw consent at any time</li>
</ul>
<p>To exercise these rights, contact us at <a href="mailto:info@cytbilisim.com">info@cytbilisim.com</a>.</p>

<h2>8. Data Security</h2>
<p>We implement industry-standard security measures including encryption in transit (TLS/SSL), secure database access controls, and regular security audits.</p>

<h2>9. Custom Images</h2>
<p>If you use the Custom Image feature, images are processed and stored <strong>locally on your device only</strong>. We do not upload, store, or access your custom images on our servers.</p>

<h2>10. Changes to This Policy</h2>
<p>We may update this Privacy Policy from time to time. We will notify you of significant changes through the App or by email.</p>

<h2>11. Contact Us</h2>
<p><strong>CYT Bilişim Hizmetleri</strong><br>
Email: <a href="mailto:info@cytbilisim.com">info@cytbilisim.com</a><br>
Website: <a href="https://pixreveal.app">pixreveal.app</a></p>
</body>
</html>"""

TERMS_OF_SERVICE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PixReveal - Terms of Service</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; color: #e0e0e0; background: #0a0a1a; line-height: 1.6; }
  h1 { color: #ff00ff; } h2 { color: #00ffff; } h3 { color: #00ff00; }
  a { color: #ff00ff; }
</style>
</head>
<body>
<h1>Terms of Service</h1>
<p><strong>Effective Date:</strong> April 8, 2026<br>
<strong>Last Updated:</strong> April 8, 2026</p>

<p>Welcome to PixReveal! These Terms of Service ("Terms") govern your use of the PixReveal mobile application ("the App") developed by <strong>CYT Bilişim Hizmetleri</strong> ("we", "us", "our"), a company based in Turkey.</p>

<h2>1. Acceptance of Terms</h2>
<p>By downloading, installing, or using the App, you agree to be bound by these Terms. If you do not agree, do not use the App.</p>

<h2>2. Eligibility</h2>
<p>You must be at least <strong>13 years old</strong> to use the App. By using the App, you represent that you meet this age requirement.</p>

<h2>3. Account</h2>
<ul>
<li>You may create an account using Apple, Google, email, or use Guest Mode.</li>
<li>You are responsible for maintaining the security of your account credentials.</li>
<li>Guest Mode accounts cannot be recovered if the app is uninstalled. We recommend linking to a permanent account.</li>
</ul>

<h2>4. In-App Purchases</h2>
<ul>
<li>The App offers in-app purchases including tokens, theme packs, and subscriptions.</li>
<li>All purchases are processed through the Apple App Store or Google Play Store via RevenueCat.</li>
<li>Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.</li>
<li>You can manage subscriptions through your device's store settings.</li>
<li>Refunds are handled according to the respective store's refund policies.</li>
</ul>

<h2>5. Virtual Currency (Tokens)</h2>
<ul>
<li>Tokens are virtual items with no real-world monetary value.</li>
<li>Tokens cannot be transferred, traded, or exchanged for real currency.</li>
<li>We reserve the right to modify token pricing and earning rates.</li>
</ul>

<h2>6. User-Generated Content</h2>
<ul>
<li>The Custom Image feature allows you to use your own images in the game.</li>
<li>Custom images are stored locally on your device only.</li>
<li>You must not use images that are illegal, obscene, or infringe on third-party rights.</li>
<li>We are not responsible for user-generated content.</li>
</ul>

<h2>7. Prohibited Conduct</h2>
<p>You agree not to:</p>
<ul>
<li>Cheat, hack, or exploit bugs in the game</li>
<li>Use automated tools or bots</li>
<li>Reverse engineer or decompile the App</li>
<li>Harass other users via leaderboards or social features</li>
<li>Attempt to manipulate leaderboard rankings</li>
</ul>

<h2>8. Intellectual Property</h2>
<p>All content in the App (graphics, music, code, game mechanics) is owned by CYT Bilişim Hizmetleri and protected by copyright laws. You may not reproduce, distribute, or create derivative works without our written permission.</p>

<h2>9. Advertisements</h2>
<p>The App displays advertisements through Google AdMob. Ad-free experience is available through in-app purchase. Ads are never shown during active gameplay.</p>

<h2>10. Termination</h2>
<p>We may suspend or terminate your account if you violate these Terms. You may delete your account at any time through Settings.</p>

<h2>11. Disclaimer of Warranties</h2>
<p>The App is provided "AS IS" without warranties of any kind. We do not guarantee uninterrupted or error-free operation.</p>

<h2>12. Limitation of Liability</h2>
<p>To the maximum extent permitted by law, CYT Bilişim Hizmetleri shall not be liable for any indirect, incidental, or consequential damages arising from your use of the App.</p>

<h2>13. Governing Law</h2>
<p>These Terms are governed by the laws of the Republic of Turkey. Any disputes shall be resolved in the courts of Istanbul, Turkey.</p>

<h2>14. Changes to Terms</h2>
<p>We may update these Terms from time to time. Continued use of the App after changes constitutes acceptance of the updated Terms.</p>

<h2>15. Contact Us</h2>
<p><strong>CYT Bilişim Hizmetleri</strong><br>
Email: <a href="mailto:info@cytbilisim.com">info@cytbilisim.com</a><br>
Website: <a href="https://pixreveal.app">pixreveal.app</a></p>
</body>
</html>"""


@router.get("/privacy", response_class=HTMLResponse)
async def privacy_policy():
    return PRIVACY_POLICY


@router.get("/terms", response_class=HTMLResponse)
async def terms_of_service():
    return TERMS_OF_SERVICE
