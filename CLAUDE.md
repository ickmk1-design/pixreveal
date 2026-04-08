# PixReveal - Retro Arcade Puzzle

## Project Overview
PixReveal is a Qix/Gals Panic style territory capture arcade puzzle game. Players reveal hidden images by capturing screen area while avoiding enemies. Features token (jeton) system inspired by real arcade machines, custom image upload for premium users, and theme-based world packs.

## Technical Stack
- **Frontend**: Flutter 3.x + Flame Game Engine
- **Backend**: FastAPI (Python 3.11+) + PostgreSQL + Redis
- **Auth**: Firebase Auth (Anonymous + Google + Apple Sign-in)
- **Ads**: Google AdMob (Interstitial + Rewarded + Banner)
- **IAP**: RevenueCat (cross-platform)
- **Analytics**: Firebase Analytics
- **Push**: Firebase Cloud Messaging
- **Storage**: AWS S3 (pixreveal-assets bucket) + CloudFront CDN
- **CI/CD**: Codemagic
- **Server**: S1 — 13.50.239.130
- **Domain**: pixreveal.app

## Package Info
- **Package Name**: com.cytbilisim.pixreveal
- **App Name**: PixReveal
- **Bundle ID (iOS)**: com.cytbilisim.pixreveal
- **Min iOS**: 13.0
- **Min Android API**: 21

## Project Structure

### Flutter App (~/projects/pixreveal/app/)
```
lib/
├── main.dart
├── game/
│   ├── pixreveal_game.dart          # Main Flame game class
│   ├── components/
│   │   ├── player.dart              # Player cursor (diamond shape)
│   │   ├── trail.dart               # Line trail when capturing
│   │   ├── territory.dart           # Captured territory manager
│   │   ├── background_image.dart    # Hidden image renderer
│   │   └── hud.dart                 # In-game HUD overlay
│   ├── enemies/
│   │   ├── enemy_base.dart          # Base enemy class
│   │   ├── spider.dart              # Random bounce (Level 1-5)
│   │   ├── worm.dart                # Wall follower (Level 6-10)
│   │   ├── spark.dart               # Edge runner (Level 11-20)
│   │   ├── ghost.dart               # Player tracker (Level 21-30)
│   │   ├── bomber.dart              # Explosion area (Level 31-40)
│   │   └── boss.dart                # Boss with patterns + spawns
│   ├── powerups/
│   │   ├── powerup_base.dart
│   │   ├── freeze.dart
│   │   ├── speed_boost.dart
│   │   ├── shield.dart
│   │   ├── bomb.dart
│   │   ├── auto_close.dart
│   │   └── extra_life.dart
│   ├── levels/
│   │   ├── level_manager.dart       # Level loading + progression
│   │   ├── level_config.dart        # Level data model
│   │   └── custom_level.dart        # Custom image level handler
│   └── utils/
│       ├── territory_calculator.dart # Polygon area calculation
│       ├── collision_detector.dart   # Line + enemy collision
│       └── game_constants.dart
├── screens/
│   ├── splash_screen.dart
│   ├── main_menu_screen.dart
│   ├── world_select_screen.dart
│   ├── level_select_screen.dart
│   ├── game_screen.dart             # Flame GameWidget wrapper
│   ├── result_screen.dart
│   ├── custom_level_screen.dart     # Image picker + difficulty select
│   ├── collection_screen.dart       # Image gallery
│   ├── shop_screen.dart             # Tokens + themes + subscriptions
│   ├── leaderboard_screen.dart
│   ├── settings_screen.dart
│   ├── achievements_screen.dart
│   └── daily_tasks_screen.dart
├── models/
│   ├── user_model.dart
│   ├── level_model.dart
│   ├── token_model.dart
│   ├── purchase_model.dart
│   ├── achievement_model.dart
│   ├── custom_level_model.dart
│   ├── daily_task_model.dart
│   └── leaderboard_model.dart
├── services/
│   ├── api_service.dart             # Backend API calls
│   ├── auth_service.dart            # Firebase Auth
│   ├── ad_service.dart              # AdMob management
│   ├── iap_service.dart             # RevenueCat
│   ├── analytics_service.dart       # Firebase Analytics
│   ├── push_service.dart            # FCM
│   ├── storage_service.dart         # Local storage (shared_prefs + hive)
│   ├── image_processor.dart         # Crop, resize, format for custom levels
│   └── audio_service.dart           # SFX + BGM management
├── providers/
│   ├── game_provider.dart
│   ├── user_provider.dart
│   ├── token_provider.dart
│   ├── theme_provider.dart
│   └── settings_provider.dart
├── widgets/
│   ├── token_display.dart           # Animated token counter
│   ├── star_rating.dart             # 1-3 star display
│   ├── power_up_bar.dart
│   ├── jeton_insert_animation.dart  # Arcade token insert animation
│   ├── neon_button.dart             # Retro neon styled button
│   ├── retro_card.dart
│   └── progress_bar.dart
└── utils/
    ├── constants.dart               # Colors, sizes, config
    ├── theme.dart                   # App theme (retro arcade)
    ├── routes.dart
    └── helpers.dart
```

### Backend (~/projects/pixreveal/backend/)
```
backend/
├── main.py                          # FastAPI app entry
├── requirements.txt
├── Dockerfile
├── docker-compose.yml               # API + PostgreSQL + Redis
├── alembic/                         # DB migrations
├── app/
│   ├── __init__.py
│   ├── config.py                    # Settings, env vars
│   ├── database.py                  # PostgreSQL connection
│   ├── redis_client.py
│   ├── models/
│   │   ├── user.py
│   │   ├── score.py
│   │   ├── purchase.py
│   │   ├── achievement.py
│   │   ├── daily_task.py
│   │   └── custom_level_share.py
│   ├── schemas/
│   │   ├── user.py
│   │   ├── score.py
│   │   ├── token.py
│   │   └── leaderboard.py
│   ├── routers/
│   │   ├── auth.py                  # /api/auth/*
│   │   ├── user.py                  # /api/user/*
│   │   ├── levels.py                # /api/levels/*
│   │   ├── leaderboard.py           # /api/leaderboard
│   │   ├── iap.py                   # /api/iap/*
│   │   ├── achievements.py          # /api/achievements
│   │   ├── daily.py                 # /api/daily/*
│   │   └── custom.py               # /api/custom/* (share links)
│   ├── services/
│   │   ├── firebase_auth.py         # Token verification
│   │   ├── revenucat_service.py     # IAP verification
│   │   └── token_service.py         # Jeton economy logic
│   └── middleware/
│       ├── auth_middleware.py
│       └── rate_limiter.py
└── nginx/
    └── pixreveal.conf               # Nginx site config
```

## Setup Commands

### 1. Create project directories
```bash
mkdir -p ~/projects/pixreveal/{app,backend}
cd ~/projects/pixreveal
```

### 2. Initialize Flutter app
```bash
cd app
flutter create --org com.cytbilisim --project-name pixreveal .
```

### 3. Add Flutter dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.18.0
  flame_audio: ^2.10.0
  flutter_riverpod: ^2.5.0
  google_mobile_ads: ^5.1.0
  purchases_flutter: ^7.0.0
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  firebase_analytics: ^11.0.0
  firebase_messaging: ^15.0.0
  share_plus: ^9.0.0
  url_launcher: ^6.3.0
  http: ^1.2.0
  shared_preferences: ^2.3.0
  path_provider: ^2.1.0
  image_picker: ^1.1.0
  image_cropper: ^7.1.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  cached_network_image: ^3.4.0
  go_router: ^14.0.0
  flutter_animate: ^4.5.0
```

### 4. Initialize backend
```bash
cd ~/projects/pixreveal/backend
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn sqlalchemy asyncpg alembic redis pydantic python-jose firebase-admin httpx
```

### 5. Docker setup
```bash
cd ~/projects/pixreveal/backend
# docker-compose.yml with:
# - api (FastAPI on port 8005)
# - postgres (if not using shared instance)
# - redis (if not using shared instance)
docker-compose up -d
```

### 6. Nginx config
```nginx
server {
    listen 80;
    server_name pixreveal.app api.pixreveal.app;

    location /api/ {
        proxy_pass http://127.0.0.1:8005;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location / {
        # Landing page / marketing site
        root /var/www/pixreveal;
        index index.html;
    }
}
```

### 7. SSL
```bash
sudo certbot --nginx -d pixreveal.app -d api.pixreveal.app
```

## CLAUDE.md Content
```markdown
# PixReveal - Retro Arcade Puzzle

## Project Description
Qix/Gals Panic inspired territory capture arcade puzzle for iOS & Android.
Built with Flutter + Flame (frontend) and FastAPI + PostgreSQL + Redis (backend).

## Key Rules
- Package: com.cytbilisim.pixreveal
- Server: S1 (13.50.239.130), Docker, Nginx reverse proxy
- Backend port: 8005
- All game logic in lib/game/ using Flame engine
- All UI screens in lib/screens/ using Flutter widgets
- State management: Riverpod (NOT setState, NOT Provider)
- IAP: RevenueCat ONLY (no direct StoreKit/BillingClient)
- Ads: AdMob - NEVER show during gameplay, only between levels
- Auth: Firebase Auth - always support anonymous login
- Custom Image: Process locally, NEVER upload to server
- Images: 1080x1920 portrait assets, JPEG compressed
- Audio: .ogg (Android) + .aac (iOS), use flame_audio
- Minimum iOS 13, Android API 21
- Turkish + English localization from day 1
- Follow existing CYT project conventions (git hooks, commit format)

## Token Economy Rules
- 1 token = 3 lives
- Daily login: 2 tokens (once/day)
- Watch ad: 1 token (max 10/day)
- 3-star level: 1 bonus token
- NEVER give unlimited free tokens
- Balance: player should need ~1-2 extra tokens/day beyond free earning

## Level Design Rules
- 80% = complete, 80%=1star, 90%=2star, 95%=3star
- Boss every 10th level
- Max 5 enemies on screen
- Enemy speed increases per world, not per level
- Custom levels: user picks difficulty (easy/medium/hard)

## Store Compliance
- NO adult/explicit content in ANY built-in assets
- Custom Image = UGC, stored locally only
- All IAP through RevenueCat
- AdMob test mode during development
- NoReject AI scan before every store submission
```

## Git Setup
```bash
cd ~/projects/pixreveal
git init
git remote add origin git@github.com:cytbilisim/pixreveal.git
```

## Firebase Setup
- Project name: pixreveal-prod
- Enable: Auth (Anonymous, Google, Apple), Analytics, Messaging
- Download google-services.json → app/android/app/
- Download GoogleService-Info.plist → app/ios/Runner/

## RevenueCat Setup
- App name: PixReveal
- Products: token packs (consumable), theme packs (non-consumable), subscriptions
- Entitlements: custom_image, premium, ad_free

## AdMob Setup
- App ID: (to be created)
- Ad units: interstitial, rewarded, banner
- Use TEST IDs during development
- Production IDs only at launch

## Codemagic Setup
- Workflow: Flutter build for iOS + Android
- Triggers: push to main branch
- Signing: Apple + Google credentials
- Distribution: TestFlight + Internal Testing

## Marketing Accounts
- Twitter: @PixRevealGame (to be created)
- Domain: pixreveal.app (to be purchased)
- Landing page on S1 at /var/www/pixreveal/

## Priority Order
1. Core game mechanic (move, draw, capture territory)
2. Single enemy type + first 11 levels
3. Token system + lives
4. UI screens (menu, game, result)
5. All enemy types + boss
6. Power-ups
7. Backend API + auth
8. AdMob + RevenueCat
9. Collection gallery
10. Custom Image feature
11. Leaderboard + social
12. Premium theme packs
13. Polish + launch
