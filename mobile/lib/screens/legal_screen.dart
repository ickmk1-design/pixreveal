import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/cyber_theme.dart';
import '../utils/localization.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String url;

  const LegalScreen({super.key, required this.title, this.url = ''});

  @override
  Widget build(BuildContext context) {
    final isPrivacy = title.toLowerCase().contains('priv') || title.contains('GIZ');
    final content = isPrivacy ? _privacyContent() : _termsContent();

    return Scaffold(
      backgroundColor: Cyber.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/settings'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Cyber.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Cyber.borderSubtle),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                        color: Cyber.textPrimary, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(title,
                    style: Cyber.title(size: 14, color: Cyber.textPrimary)),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  content,
                  style: Cyber.body(size: 14, color: Cyber.textSecondary, weight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _privacyContent() {
    if (L.isTr) {
      return '''GİZLİLİK POLİTİKASI

Son güncelleme: Nisan 2026

CYT Bilişim olarak gizliliğinize önem veriyoruz. Bu politika, PixReveal uygulaması aracılığıyla hangi verileri topladığımızı, nasıl kullandığımızı ve koruduğumuzu açıklar.

1. TOPLANAN VERİLER
• Anonim kimlik (Firebase Auth UID)
• Oyun ilerlemesi (tamamlanan bölümler, yıldızlar, jetonlar)
• Uygulama kullanım analitikleri (Firebase Analytics)
• Satın alma bilgileri (RevenueCat üzerinden)
• Cihaz bilgileri (model, işletim sistemi)

2. KULLANIM AMAÇLARI
• Oyun ilerlemenizi cihazlar arası senkronize etmek
• Performans ve hata izleme
• İstatistikler ve analiz
• Satın alma doğrulama

3. ÜÇÜNCÜ TARAF HİZMETLERİ
• Firebase (Google) — kimlik ve analitik
• RevenueCat — abonelik yönetimi
• Google AdMob — reklam gösterimi
• Apple/Google Play — ödeme işlemleri

4. REKLAM
Uygulama reklamlar gösterebilir. Reklamlar AdMob tarafından yönetilir ve kişiselleştirilmiş olmayabilir. Cihazınızda bir reklam kimliği saklanır.

5. ÇOCUKLAR
PixReveal 12+ yaş için tasarlanmıştır. 13 yaş altı kullanıcılardan bilerek kişisel veri toplamayız.

6. HAKLARINIZ
• Hesap silme talep edebilirsiniz (Ayarlar > Hesabı Sil)
• Verilerinizin kopyasını isteyebilirsiniz
• İletişim: info@cytbilisim.com

7. GÜNCELLEMELER
Bu politika zaman zaman güncellenebilir. Önemli değişikliklerde uygulama içinde bildirim gösterilecektir.

İletişim: info@cytbilisim.com''';
    }
    return '''PRIVACY POLICY

Last updated: April 2026

CYT Bilisim respects your privacy. This policy explains what data we collect through the PixReveal app, how we use it, and how we protect it.

1. DATA WE COLLECT
• Anonymous identity (Firebase Auth UID)
• Game progress (completed levels, stars, tokens)
• App usage analytics (Firebase Analytics)
• Purchase information (via RevenueCat)
• Device information (model, OS version)

2. HOW WE USE DATA
• Sync your game progress across devices
• Performance and crash monitoring
• Statistics and analytics
• Purchase verification

3. THIRD-PARTY SERVICES
• Firebase (Google) — identity and analytics
• RevenueCat — subscription management
• Google AdMob — ad serving
• Apple/Google Play — payment processing

4. ADVERTISING
The app may display ads. Ads are managed by AdMob and may not be personalized. An advertising ID is stored on your device.

5. CHILDREN
PixReveal is designed for ages 12+. We do not knowingly collect personal data from users under 13.

6. YOUR RIGHTS
• You can request account deletion (Settings > Delete Account)
• You can request a copy of your data
• Contact: info@cytbilisim.com

7. UPDATES
This policy may be updated from time to time. Significant changes will be announced in the app.

Contact: info@cytbilisim.com''';
  }

  String _termsContent() {
    if (L.isTr) {
      return '''KULLANIM ŞARTLARI

Son güncelleme: Nisan 2026

PixReveal uygulamasını indirmek, yüklemek veya kullanmakla bu şartları kabul etmiş sayılırsınız.

1. HİZMETİN KULLANIMI
PixReveal, CYT Bilişim tarafından geliştirilen bir mobil oyundur. Uygulamayı kişisel, ticari olmayan amaçlarla kullanabilirsiniz.

2. HESAP
Misafir olarak oynayabilir veya hesabınızı bağlayabilirsiniz. Hesap bilgilerinizi koruma sorumluluğu size aittir.

3. SATIN ALMALAR
Uygulama içi satın alımlar geri ödenmez. Tüm satın almalar App Store veya Google Play üzerinden işlenir ve onların politikalarına tabidir.

4. KULLANICI İÇERİĞİ
Premium kullanıcılar kendi resimlerini yükleyebilir. Yüklediğiniz içerikten siz sorumlusunuz. Yasa dışı, müstehcen veya telif haklarını ihlal eden içerik yüklemeyin.

5. FİKRİ MÜLKİYET
PixReveal logosu, oyun mekaniği ve dahili görseller CYT Bilişim mülkiyetindedir. İzinsiz kopyalanamaz.

6. SORUMLULUK REDDİ
Uygulama "olduğu gibi" sunulur. Kesintisiz veya hatasız çalışacağı garanti edilmez.

7. FESİH
Bu şartları ihlal ettiğinizi tespit edersek hesabınızı askıya alma veya silme hakkımızı saklı tutarız.

8. İLETİŞİM
Sorularınız için: info@cytbilisim.com''';
    }
    return '''TERMS OF SERVICE

Last updated: April 2026

By downloading, installing, or using the PixReveal app, you accept these terms.

1. USE OF SERVICE
PixReveal is a mobile game developed by CYT Bilisim. You may use the app for personal, non-commercial purposes.

2. ACCOUNT
You may play as a guest or link your account. You are responsible for maintaining the security of your account credentials.

3. PURCHASES
In-app purchases are non-refundable. All purchases are processed through the App Store or Google Play and subject to their policies.

4. USER CONTENT
Premium users may upload their own images. You are responsible for the content you upload. Do not upload illegal, obscene, or copyright-infringing content.

5. INTELLECTUAL PROPERTY
The PixReveal logo, game mechanics, and built-in art are property of CYT Bilisim. Unauthorized copying is prohibited.

6. DISCLAIMER
The app is provided "as is". We do not guarantee uninterrupted or error-free operation.

7. TERMINATION
We reserve the right to suspend or delete accounts that violate these terms.

8. CONTACT
For questions: info@cytbilisim.com''';
  }
}
