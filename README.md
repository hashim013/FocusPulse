# Focus Pulse: Mood & Study Tracker 🚀

<p align="center">
  <img src="assets/banner.png" width="600" height="300" alt="Focus Pulse Banner">
</p>
**Focus Pulse** is a high-performance, premium Flutter application designed to revolutionize how students manage their academic life. Built with **Material 3** aesthetics and a focus on modularity, it combines a Pomodoro timer, task management, and deep behavioral analytics into a single "Student OS."

---

## ✨ Key Features

-   **🎯 Focus Timer**: High-precision Pomodoro clock with customizable sessions to maximize deep work.
-   **📈 Advanced Analytics**: Visualize your productivity "Pulse" with Line, Bar, and Pie charts powered by `fl_chart`.
-   **📝 Session Logging**: Keep track of every study minute, your mood, and specific subjects.
-   **🔔 Smart Notifications**: Intelligent daily reminders synchronized with your local timezone to keep you on schedule.
-   **📄 Data Export**: Generate professional PDF reports of your study logs for physical tracking.
-   **🌓 Modern Theming**: Sleek Dark/Light mode support using a curated Teal & Slate color palette.

---

## 🛠️ Tech Stack & Packages

Focus Pulse uses a modern, high-speed stack for the best user experience:

-   **Database**: `Hive` & `Hive Flutter` (Ultra-fast NoSQL local storage).
-   **Charts**: `fl_chart` (Reactive data visualization).
-   **PDF/Printing**: `pdf` & `printing` (Native document generation).
-   **Notifications**: `flutter_local_notifications` & `timezone` (Platform-specific reminders).
-   **UI**: Material 3, `google_fonts`, and custom glassmorphic components.

---

## 🏗️ Architecture

The project follows a **Clean Modular Architecture**:

-   `core/`: Application-wide themes, constants, and global services (Notifications, Insights).
-   `data/`: Domain models and Hive TypeAdapters.
-   `presentation/`: Feature-based UI modules (Analytics, Focus, Tasks, Logs, Settings).

---

## 🧠 Solved Technical Challenges

### 1. The Initialization "White Screen"
We solved the common Flutter initialization race condition by re-ordering the `main()` async sequence, ensuring Hive boxes and notification services are warm before the first frame is rendered.

### 2. Timezone Synchronization
Fixed a critical bug where `flutter_timezone` returned inconsistent types on different platforms. Implemented a defensive mapping layer that guarantees notification accuracy regardless of the device's OS version.

### 3. Gap-Filling Chart Logic
To prevent broken lines in the 30-day productivity chart, we built a data-mapping engine that automatically fills zero-hour study days, providing a smooth and continuous visual experience.

---

## ⚙️ How to Run

1.  **Clone the Repo**:
    ```bash
    git clone https://github.com/[YOUR_USERNAME]/focus_pulse.git
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Generate Hive Adapters**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 🤝 Project Evaluation
This project was built to showcase:
- Clean and maintainable codebase.
- Advanced reactive state management using `ValueListenableBuilder`.
- Sophisticated local data persistence.
- Premium UI/UX implementation.

---

*Designed and Developed by [Your Name]*
