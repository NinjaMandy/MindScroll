# MindScroll 📱

MindScroll is a premium, offline-first digital wellbeing Android application built using Flutter and native Kotlin. Unlike traditional wellbeing applications that measure screen time, MindScroll measures **the exact count of short-form content** (YouTube Shorts, Instagram Reels, Facebook Reels, and TikTok) that you consume each day.

The app uses Android's Accessibility Service to track swipes and new videos dynamically and overlays a real-time counter to promote conscious scrolling. It works entirely offline with no internet access, no accounts, and no third-party cloud databases—keeping your data private on your device.

---

## Project Structure

```
mindscroll/
├── .github/workflows/
│   └── build_apk.yml            # CI/CD release build pipeline
├── pubspec.yaml                 # Dependencies (Riverpod, Isar, fl_chart)
├── lib/
│   ├── main.dart                # Entry point, DB configuration, provider startup
│   └── src/
│       ├── core/
│       │   ├── models/
│       │   │   ├── daily_stats.dart   # Isar schema for daily counts
│       │   │   └── unlock_record.dart # Isar schema for unlock auditing
│       │   ├── storage/
│       │   │   ├── state_manager.dart # JSON loader & DB syncing
│       │   │   └── history_provider.dart # History stats calculator
│       │   └── theme/
│       │       └── app_theme.dart     # Material 3 light/dark style declarations
│       └── features/
│           ├── home/
│           │   └── presentation/
│           │       └── home_shell.dart # Main Navigation shell
│           ├── dashboard/
│           │   └── presentation/
│           │       └── dashboard_screen.dart # Progress circle & platform breakdowns
│           ├── analytics/
│           │   └── presentation/
│           │       └── analytics_screen.dart # fl_chart weekly & monthly bar charts
│           └── settings/
│               └── presentation/
│                   └── settings_screen.dart # Configuration for limits & positions
└── android/
    ├── gradle.properties        # Project settings (AndroidX and Jetifier)
    ├── build.gradle             # Modern Gradle build setup (Plugin DSL)
    ├── settings.gradle          # Modern Gradle settings (Plugin DSL)
    └── app/
        ├── build.gradle         # App-level AGP target & settings
        └── src/main/
            ├── AndroidManifest.xml # Service registration & MainActivity bindings
            ├── res/
            │   ├── xml/
            │   │   └── accessibility_service_config.xml # Events mapping
            │   ├── values/
            │   │   ├── strings.xml  # Accessibility labels
            │   │   └── styles.xml   # App styles fallback
            │   └── drawable/
            │       └── launch_background.xml
            └── kotlin/com/example/mindscroll/
                ├── MainActivity.kt # Check/request Accessibility permissions channel
                └── MindScrollAccessibilityService.kt # Foreground detection, signature parsing, blocking overlays
```

---

## Project Architecture

MindScroll implements a decoupled, battery-efficient sync architecture. The native accessibility tracker runs continuously in the background, writing event increments to a shared file, which the premium Flutter UI syncs to a local Isar database.

```mermaid
graph TD
    subgraph Background (Kotlin Service)
        A[Accessibility Service]
        B[Floating Counter Overlay]
        C[Full-Screen Block Overlay]
    end

    subgraph Sandbox Directory
        D[(mindscroll_state.json)]
    end

    subgraph Foreground (Flutter UI)
        E[StateManager]
        F[(Isar Local DB)]
        G[Dashboard, Charts & Settings]
    end

    A -->|Tracks scrolling & updates| D
    E -->|Reads state file & syncs| F
    E -->|Updates settings| D
    A -->|Renders feedback| B
    A -->|Blocks apps if limit met| C
    F -->|Populates| G
```

1. **`mindscroll_state.json`**: Located in the application's internal files directory (`context.filesDir`). Both Kotlin and Dart can read/write this file. It contains the current day's counts, goal settings, and active emergency unlocks.
2. **Isar Database**: Exclusively managed by Dart. It stores historical records, daily averages, weekly/monthly summaries, and unlock logs.
3. **Decoupled Synchronization**: When the Flutter app opens or resumes, it parses the JSON file, migrates the new counts into Isar for permanent historical charts, and writes updated settings (e.g. new limit or disabled apps) back to the JSON.

---

## How the Accessibility Service Works

The background tracking is handled by the native `MindScrollAccessibilityService` in Kotlin.

1. **Foreground App Detection**: The service filters incoming window events to listen only to the target package names:
   * **YouTube** (`com.google.android.youtube`)
   * **Instagram** (`com.instagram.android`)
   * **Facebook** (`com.facebook.katana`)
   * **TikTok** (`com.zhiliaoapp.musically` or `com.ss.android.ugc.trill`)
2. **Short-Form Layout Filtering**: When the active package changes, the service traverses the active window node tree. It verifies that a short-form player layout is active (e.g., matching IDs containing `reel_viewer`, `shorts_player_view`, or matching elements layout). If the user is on the YouTube Home screen or Instagram Messages, tracking is paused.
3. **Content Signature Matching**: To avoid counting double clicks, layout adjustments, comments drawer expansions, or scroll gestures as "new content", the service performs a Depth-First Search (DFS) on the node hierarchy to extract distinct texts (such as the creator's username and the video description). These are combined into a unique **Content Signature**.
4. **FIFO Cache Filtering**: The service keeps a small FIFO cache of the last 10 signatures. An increment is only made if the signature changes to one not present in the cache, allowing the user to view comments or scroll back without counting duplicates.

---

## How the Overlays Work

The service displays two types of overlays depending on your daily limit status. Since the overlays are drawn by the Accessibility Service, they utilize the `TYPE_ACCESSIBILITY_OVERLAY` window parameter. This allows the overlays to display without requiring the intrusive "Draw over other apps" (System Alert Window) permission.

### 1. Floating Counter Overlay
* **Behavior**: Appears immediately at a corner of the screen when a new Short or Reel is watched.
* **Layout**: A sleek rounded pill colored in Deep Indigo (`#4F46E5`) displaying `📱 Current Count / Daily Goal`.
* **Animation**: Fades in, stays visible for 1.5 seconds, and fades out. It does not obstruct navigation buttons or comments.

### 2. Full-Screen Blocking Screen
* **Behavior**: If the daily limit is exceeded, opening a tracked application immediately blocks access by overlaying a solid Charcoal (`#121212`) screen.
* **Content**: Displays today's count, estimated viewing time, and an encouraging mindfulness message.
* **Actions**:
  * **Close Application**: Performs a global `GLOBAL_ACTION_HOME` command, minimizing the blocked application and returning the user to the home screen.
  * **Emergency Unlock**: Allows selecting an override duration (15 minutes, 30 minutes, 1 hour, or until tomorrow) to unlock scrolling. These unlock events are written to the local audit log.

---

## Permissions Explanation

To function correctly, the application requires the following Android permissions:

* **`android.permission.BIND_ACCESSIBILITY_SERVICE`**: Required to register as an Accessibility Service. This allows the app to detect scroll events, examine layout node hierarchies to identify content signatures, and draw UI overlays.
* **No Network Permissions**: The application does not declare internet access in `AndroidManifest.xml`, guaranteeing that your scrolling history never leaves your device.

---

## Local Setup & Build Instructions

### Prerequisites
* Flutter SDK (v3.0.0 or higher)
* Android SDK (API Level 21 or higher)
* Java JDK (v11 or higher)

### Setup Steps
1. **Clone the Repository** and navigate to the project directory:
   ```bash
   cd mindscroll
   ```

2. **Retrieve Flutter Packages**:
   ```bash
   flutter pub get
   ```

3. **Generate Isar Database Adapters**:
   MindScroll uses Isar database collections, which generate boilerplate serialization adapters. Run the builder to generate these files:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Connect a Device** (Emulator or physical Android device with Developer Options enabled) and build the application:
   ```bash
   flutter run
   ```

5. **Enable the Accessibility Service**:
   * Open the app.
   * Tap the **Enable in Settings** card on the dashboard.
   * Go to **Downloaded Services** > **MindScroll** > Toggle **On**.

---

## Generating the APK from GitHub Actions

This repository includes a pre-configured GitHub Actions workflow in `.github/workflows/build_apk.yml` to compile the app without needing local Flutter installations.

### Automatic Builds
The build pipeline triggers automatically whenever you:
1. **Push** a commit to your `main` or `master` branch.
2. **Merge** a pull request into `main` or `master`.

### Manual Builds (Workflow Dispatch)
You can manually run the build via GitHub's web interface:
1. Go to your repository page on GitHub.
2. Select the **Actions** tab at the top.
3. In the left-hand sidebar, select the **Build Release APK** workflow.
4. Click the **Run workflow** dropdown on the right, select the branch (`main`), and click the green **Run workflow** button.

### How to Download the Built APK
1. Wait for the build workflow to finish running (typically takes 4-5 minutes).
2. Click on the completed run (it will have a green checkmark).
3. Scroll down to the **Artifacts** section at the bottom of the summary page.
4. Click on `release-apk` to download the zip file containing the compiled `app-release.apk`.
5. Unzip and install `app-release.apk` on your Android device!
