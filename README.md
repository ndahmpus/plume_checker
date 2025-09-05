# 🚀 Plume Portal Checker

<div align="center">
  <img src="assets/plume_logo.png" alt="Plume Portal Logo" width="200">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.24.x-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.8.1+-blue.svg)](https://dart.dev/)
  [![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-green.svg)](https://flutter.dev/multi-platform)
  [![License](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE)

  **Portal Checker - Comprehensive Plume Portal Statistics and Wallet Analytics**
  
  *A powerful Flutter application for tracking wallet activities, portfolio analytics, and comprehensive statistics in the Plume blockchain ecosystem.*

</div>

---

## 📱 Features

### 🔍 **Wallet Analytics**
- **Real-time Portfolio Tracking** - Monitor your wallet balance and token distributions
- **Multi-Token Support** - Track various tokens across the Plume ecosystem
- **Portfolio Diversity Analysis** - Calculate and display portfolio diversification metrics
- **Historical Data** - View wallet activity history and trends

### 📊 **Portal Statistics**
- **Comprehensive Portal Stats** - Bridge volume, swap statistics, TVL data
- **XP Tracking** - Monitor your experience points and ranking
- **Protocol Usage** - Track protocols used and quest completions
- **Staking Analytics** - Plume staking data, streaks, and rewards

### 🏆 **Gamification Features**
- **Tier System** - Phoenix, Eagle, Hawk, Falcon, Raven, Pigeon, Sparrow, Egg tiers
- **Badge Collection** - Track and display earned badges
- **Daily Spin** - Monitor daily spin streaks and rewards
- **Referral System** - Track referrals and bonus XP

### 💼 **DeFi Integration**
- **TVL Monitoring** - Total Value Locked tracking with real-time updates
- **Swap Analytics** - Volume tracking and swap count statistics
- **Yield Farming** - Season 1 allocation tracking and portfolio management
- **Bridge Statistics** - Cross-chain bridge volume analysis

### 🎨 **User Experience**
- **Futuristic UI** - Dark theme with neon accents and modern design
- **Responsive Design** - Optimized for various screen sizes
- **Smart Caching** - 5-minute cache system for optimal performance
- **Wallet History** - Quick access to recently checked wallets
- **Error Handling** - Graceful error management with user-friendly messages

---

## 📸 Screenshots

<div align="center">

### 🔍 **Wallet Input & Search**
<img src="screenshots/01-wallet-input.png" alt="Wallet Input Screen" width="300">

*Clean, futuristic interface for entering wallet addresses with history*

### 📊 **Dashboard & Statistics** 
<img src="screenshots/02-dashboard.png" alt="Dashboard Statistics" width="300">

*Comprehensive portal statistics showing XP, rankings, and TVL data*

### 💼 **Portfolio Analytics**
<img src="screenshots/03-portfolio.png" alt="Portfolio Analytics" width="300">

*Real-time portfolio tracking with token distribution and diversity metrics*

### 🏆 **Tier System & Badges**
<img src="screenshots/04-tier-system.png" alt="Tier System" width="300">

*Gamification features with tier progression and badge collection*

### 💰 **DeFi Integration**
<img src="screenshots/05-defi-stats.png" alt="DeFi Statistics" width="300">

*Advanced DeFi analytics including swap data and yield farming metrics*

</div>

---

## 🏗️ Architecture

### **Clean Architecture Pattern**
```
lib/
├── 📁 core/           # Core business logic and base classes
├── 📁 models/         # Data models and JSON serialization
├── 📁 services/       # API services and external integrations
├── 📁 providers/      # State management (Provider pattern)
├── 📁 screens/        # UI screens and page controllers
├── 📁 widgets/        # Reusable UI components
├── 📁 utils/          # Helper functions and utilities
└── 📁 constants/      # App constants and configurations
```

### **Tech Stack**
- **Frontend**: Flutter (Cross-platform mobile app)
- **State Management**: Provider pattern
- **HTTP Client**: Dart HTTP package with custom client configurations
- **Local Storage**: SharedPreferences for caching and wallet history
- **Blockchain Integration**: web3dart for Ethereum-compatible interactions
- **Serialization**: JSON annotation with code generation

### **External APIs**
- **Plume Portal API** - Main portal statistics and wallet data
- **Nucleus Earn API** - Portfolio and DeFi analytics
- **Multi-chain Support** - Integration with various blockchain networks

---

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK >= 3.24.0
- Dart SDK >= 3.8.1
- Android Studio / VS Code
- Git

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/plume_portal.git
   cd plume_portal
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (if needed)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release
   ```

### **Building for Production**

#### **Android APK**
```bash
flutter build apk --release
```

#### **Android App Bundle**
```bash
flutter build appbundle --release
```

#### **iOS**
```bash
flutter build ios --release
```

---

## 🔧 Configuration

### **Android Signing** (For Release Builds)

1. **Create keystore** (if you don't have one):
   ```bash
   keytool -genkey -v -keystore android/keystore/your-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your-key-alias
   ```

2. **Configure signing**:
   - Copy `android/key.properties.example` to `android/key.properties`
   - Update with your keystore information:
     ```properties
     storeFile=keystore/your-keystore.jks
     storePassword=YOUR_STORE_PASSWORD
     keyAlias=YOUR_KEY_ALIAS
     keyPassword=YOUR_KEY_PASSWORD
     ```

3. **Build signed APK**:
   ```bash
   flutter build apk --release
   ```

### **Environment Configuration**

The app connects to the following APIs:
- **Plume Portal API**: `https://portal-backend.plume.technology/api/v1/`
- **Nucleus Earn API**: `https://backend.nucleusearn.io/v1/plume`

No additional API keys required for basic functionality.

---

## 🎯 Usage

### **Basic Workflow**
1. **Launch the app** - You'll see the wallet input screen
2. **Enter wallet address** - Input a valid Ethereum address (0x...)
3. **View statistics** - Comprehensive analytics will be displayed
4. **Navigate sections** - Explore different data categories
5. **Cache system** - Data is cached for 5 minutes for optimal performance

### **Key Features Usage**

#### **Portfolio Analysis**
- Real-time balance tracking
- Token distribution charts
- Portfolio diversity scoring
- Top asset highlighting

#### **XP and Ranking System**
- View current XP and global ranking
- Track XP gain from various activities
- Monitor referral bonus XP

#### **DeFi Statistics**
- TVL (Total Value Locked) monitoring
- Swap volume and count tracking
- Bridge transaction analysis
- Yield farming portfolio

---

## 📂 Project Structure

<details>
<summary><strong>📁 Core Services</strong></summary>

```
lib/services/
├── plume_api_service.dart     # Main Plume Portal API integration
├── nucleus_earn_service.dart  # Portfolio and DeFi analytics
├── cache_service.dart         # Smart caching system
└── wallet_history_service.dart # Wallet history management
```
</details>

<details>
<summary><strong>🎨 UI Components</strong></summary>

```
lib/widgets/
├── portfolio_widgets.dart         # Portfolio display components
├── plume_badges_widget.dart      # Badge collection UI
├── season1_allocation_widget.dart # Season 1 specific components
├── enso_wallet_balances_widget.dart # Balance display widgets
└── optimized_loading_screen.dart # Performance-optimized loading
```
</details>

<details>
<summary><strong>📊 Data Models</strong></summary>

```
lib/models/
├── plume_portal_models.dart   # Main portal data structures
├── nucleus_earn_models.dart   # Portfolio and earn models
└── portal_stats_models.dart   # Statistics data models
```
</details>

---

## ⚡ Performance Features

### **Smart Caching System**
- **5-minute cache** for API responses
- **Persistent storage** using SharedPreferences
- **Cache invalidation** on manual refresh
- **Memory optimization** for large datasets

### **Optimized Loading**
- **Progressive loading** for better user experience
- **Skeleton screens** during data fetching
- **Error boundaries** for graceful failure handling
- **Background refresh** capabilities

### **Network Optimization**
- **Request debouncing** to prevent API spam
- **Retry mechanisms** with exponential backoff
- **Connection timeout** handling
- **Offline capability** with cached data

---

## 🛠️ Development

### **Code Generation**
The project uses code generation for JSON serialization:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### **Testing**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### **Debugging**
- Enable debug mode for detailed logging
- Use Flutter Inspector for UI debugging
- Network calls are logged in debug mode

---

## 🚨 Troubleshooting

### **Common Issues**

#### **Build Errors**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

#### **Cache Issues**
- Clear app data or use "Refresh" button in the app
- Cache is automatically cleared after 5 minutes

#### **Network Issues**
- Check internet connection
- Verify wallet address format (must start with 0x)
- Some features require specific API availability

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### **Code Style**
- Follow Dart style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Maintain consistent formatting

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

If you encounter any issues or have questions:

- **GitHub Issues**: [Create an issue](https://github.com/yourusername/plume_portal/issues)
- **Email**: your-email@example.com
- **Documentation**: Check the code comments and this README

---

## 🌟 Acknowledgments

- **Plume Network** - For the amazing blockchain ecosystem
- **Flutter Team** - For the excellent cross-platform framework
- **Community** - For feedback and contributions

---

<div align="center">
  
  **⭐ If you found this project helpful, please give it a star! ⭐**
  
  **Made with ❤️ for the Plume ecosystem**
  
</div>
