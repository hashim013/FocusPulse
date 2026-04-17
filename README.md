<p align="center">
  <img src="assets/banner.png" width="100%" height="400" alt="FocusPulse Banner">
</p>

# 📱 FocusPulse – Student OS & Productivity Tracker

A sleek, modern, and high-performance Productivity Dashboard for students. **FocusPulse** helps users manage their study sessions, track their mood, visualize progress with advanced charts, and maintain a consistent focus flow—all with persistent local storage.

Built with **Modern Clean Architecture**, premium UI/UX, and high stability.

---

## 🚀 Features

### ⏱️ Focus & Timer
- **Live Focus Session**: Pomodoro-inspired timer for deep work.
- **Dynamic Logging**: Sessions are automatically recorded with mood and duration.
- **Session Control**: Start, pause, and stop tracking with ease.

### 📊 Advanced Analytics
- **Visual Trends**: Weekly Productivity charts using `fl_chart`.
- **Mood Correlation**: Discover how your mood affects your study efficiency.
- **Smart Insights**: AI-style calculations to find your "Most Productive Mood".

### 📝 Record Management (CRUD)
- **Log System**: View a complete history of all study sessions.
- **Full Control**: Add missed sessions, edit existing ones, or delete records.
- **Persistence**: Every record is saved instantly to local storage.

### 📄 Data Exports
- **CSV Export**: Take your raw data to Excel or Google Sheets.
- **PDF Reports**: Generate professional, formatted PDF summaries of your progress.
- **Printing**: Direct support for printing reports from the app.

### 🎨 Premium UI & Theme
- **Dark & Light Mode**: Seamless theme switching with system-wide adaptation.
- **Dynamic Theme Persistence**: Remembers your preference even after restart.
- **Google Fonts**: Stylish typography for a premium look and feel.

### 💾 Storage & Reliability
- **Hive NoSQL**: Ultra-fast local storage. No internet required.
- **Instant Persistence**: Data survives app restarts and crashes.
- **Offline First**: Works 100% offline with no data loss.

---

## 📸 App Flow

**Splash Screen** (Branding) → **Home Dashboard** (Status) → **Focus Tab** (Timer) → **Analytics** (Charts) → **Logs** (CRUD) → **Settings** (Themes & Exports)

---

## 🏗️ Project Structure

```text
lib/
├── core/
│   ├── theme/           # App-wide styling and color systems
│   └── utils/           # Logic for Exports, Notifications, and Analytics
│
├── data/
│   └── models/          # Hive Data Models (TrackerSession)
│
├── presentation/
│   ├── analytics/       # Charting & Progress Visualization
│   ├── focus/           # Pomodoro/Focus Session UI
│   ├── home/            # Main navigation & Splash Screen
│   ├── logs/            # History CRUD Interface
│   ├── settings/        # Preferences & Data Tools
│   └── widgets/         # Reusable UI Components
│
└── main.dart            # Multi-service initialization (Hive, Notifications)
```

### 📌 Detailed Logic Explanation
- **Data Storage**: Uses **Hive** boxes for millisecond-fast read/write operations. TypeAdapters ensure Dart objects are stored efficiently.
- **Analytics Engine**: The `InsightsCalculator` processes raw Hive data to calculate averages and productivity peaks.
- **Notification Service**: Schedules daily study reminders using `flutter_local_notifications` with timezone awareness.

---

## 🛠️ Technologies Used

- **Flutter & Dart** - Core Framework.
- **Hive** - NoSQL database for local persistence.
- **fl_chart** - Advanced data visualization.
- **pdf & printing** - Professional report generation.
- **flutter_local_notifications** - Smart scheduling.
- **google_fonts** - Enhanced aesthetics.

---

## ⚙️ Installation

1️⃣ **Clone repository**
```bash
git clone https://github.com/your-username/focus-pulse.git
cd focus_pulse
```

2️⃣ **Install dependencies**
```bash
flutter pub get
```

3️⃣ **Run the project**
```bash
flutter run
```

---

## 🧠 Key Concepts Implemented

- **Clean Layered Architecture** (Core, Data, Presentation).
- **Service Pattern** for Notifications and File Exports.
- **NoSQL Schema Management** with Hive Adapters.
- **Data Visualization** logic for productivity trends.
- **Custom Theme System** with ValueListenable observers.

---

## 💡 Challenges Faced

| Problem | Solution |
| :--- | :--- |
| **Data Synchronization** | Implemented `ValueListenableBuilder` to reactively update UI when Hive data changes. |
| **Complex Charting** | Created custom mapping logic to translate raw study hours into formatted `LineChart` data. |
| **Notification Scheduling** | Handled timezone initialization for accurate daily study reminders across regions. |
| **State Persistence** | Managed timer states and theme preferences using dedicated Hive boxes. |

---

## 🔮 Future Roadmap

- [ ] Firebase Cloud Sync for multi-device support.
- [ ] Gamification (Badges and Leveling system).
- [ ] Integration with Google Calendar.
- [ ] AI-Powered Study Schedule Generator.

---

## 🤝 Contributing

This project is a high-quality Student OS portfolio. Contributions are welcome!
1. Fork the repo. 2. Create your Feature Branch. 3. Commit your changes. 4. Push to the Branch. 5. Open a Pull Request.

---

## 📄 License

This project is open-source and available under the **MIT License**.

---

## 🙋 Author
**Muhammad Hashim**  
*Flutter Developer | Student | Product Designer*

📧 [Connect with me on LinkedIn](https://www.linkedin.com/in/your-profile) | ⭐ Star the repo if you like it!
