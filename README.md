# PocketNest - Family Finances Simplified

A premium Flutter mobile application for family finances with beautiful UI/UX and state-driven architecture.

**Not just another money saving app** - Doing UI/UX in a better way!

**Work in progress — NOT DONE YET.**

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10.1+
- Dart 3.10.1+
- Supabase account (free tier works)

### Setup (3 steps)
1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Add your Supabase credentials:**
   - Go to [Supabase Dashboard](https://app.supabase.com)
   - Get your URL and Anon Key
   - Paste into `.env`

3. **Run the app:**
   ```bash
   flutter pub get
   flutter run
   ```

## ✨ Key Features

### Completed
- ✅ **State-Driven Navigation** - No manual Navigator.push calls
- ✅ **Splash Screen** - Professional 2-second intro
- ✅ **Auth Screen** - Google, Apple, and Phone options
- ✅ **Supabase Integration** - Backend-ready
- ✅ **Beautiful Theme** - Soft colors, premium design
- ✅ **Smooth Animations** - Fade transitions between screens
- ✅ **Security** - Environment variables for credentials

### Architecture Highlights
- 🏗️ **Flutter Bloc (Cubit)** - Clean state management
- 🎨 **Centralized Theme** - Easy customization
- 📦 **Feature-Based Structure** - Scalable organization
- 🔒 **Row Level Security** - Secure Supabase setup
- 📱 **Responsive Design** - Works on all screen sizes

---

## 🎯 App Flow

```
Launch
  ↓
[SplashState] → 2 seconds
  ↓
Check Auth
  ├─→ No User → [UnauthenticatedState] → Auth Screen
  │
  └─→ Has Session
      ├─→ Profile Incomplete → Profile Completion Screen
      └─→ Profile Complete → Home Screen
```

---

## 🎨 Design System

### Color Palette
- **Background**: Soft beige (#F5F1ED)
- **Primary**: Muted teal (#5B7C7E)
- **Accent**: Soft peach (#E8B4A8)
- **Button**: Dark teal (#32575A)

### Typography
- **Headlines**: Playfair Display (serif)
- **Body**: Inter (sans-serif)

### Components
- Rounded corners (12-16px)
- Soft shadows
- Premium feel
- Minimal aesthetic

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry point
├── config/
│   ├── environment_config.dart     # .env reader
│   └── supabase_config.dart        # Backend setup
├── core/
│   ├── theme/
│   │   └── app_theme.dart         # Centralized theme
│   └── navigation/
│       └── cubit/
│           ├── app_flow_cubit.dart
│           └── app_flow_state.dart
├── features/
│   ├── splash/
│   │   └── screens/splash_screen.dart
│   ├── auth/
│   │   └── screens/auth_screen.dart
│   └── [other features...]
└── assets/
```

---

## 🔐 Security

### ✅ Best Practices
- Environment variables in `.env` (git-ignored)
- Never hardcode credentials
- OAuth for secure authentication
- Row Level Security (RLS) in Supabase
- Secure storage ready

### Setup
1. Create `.env` from `.env.example`
2. Add Supabase credentials
3. Never commit `.env` to git
4. Share only `.env.example` with team

---

## 📱 Screens

### Splash Screen
- 2-second duration
- Woman image (circular)
- PocketNest logo
- Fade animation
- No interactions

### Auth Screen
- Logo at top
- "Family Finances Simplified" headline
- Three auth options:
  - Continue with Phone (dark teal)
  - Continue with Google
  - Continue with Apple
- Terms & Conditions link

### Placeholders (Ready to Implement)
- Profile Completion Screen
- Home/Main Screen
- And more...

---

## 🛠️ Technology Stack

- **Framework**: Flutter 3.10.1+
- **State Management**: Flutter Bloc 8.1.5 (Cubit)
- **Backend**: Supabase 2.2.0
- **Authentication**: OAuth (Google, Apple), Phone OTP
- **Fonts**: Google Fonts
- **Icons**: Font Awesome Flutter
- **SVG**: Flutter SVG

---

## 🚀 Development

### Run the app
```bash
flutter run
```

### Hot reload
Press `R` in terminal (for code changes)

### Hot restart
Press `Shift+R` in terminal (for state/const changes)

### Build for Android
```bash
flutter build apk --release
```

### Build for iOS
```bash
flutter build ios --release
```

### Clean rebuild
```bash
flutter clean && flutter pub get && flutter run
```

---

## 📊 Current Status: Phase 1 Complete ✅

### What's Done
- ✅ Core architecture & state management
- ✅ Theme system
- ✅ Splash & Auth screens
- ✅ Supabase integration
- ✅ Security setup (env variables)


## 🐛 Troubleshooting

### Common Issues
**".env not found"**
```bash
cp .env.example .env
# Edit with your Supabase credentials
flutter clean && flutter run
```

**"No provider found for AppFlowCubit"**
- Check main.dart has BlocProvider setup
- Run hot restart (Shift+R)

**"Supabase connection failed"**
- Verify `.env` has correct URL and key
- Check internet connection

---

## 🤝 Contributing

To contribute:
1. Create a feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

---

## 📄 License

MIT License - See LICENSE file for details
---

Made with ❤️ for family finances.

**Current Date**: February 5, 2026
