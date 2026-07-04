# MindScroll 📱

MindScroll is a premium, offline-first digital wellbeing Android application built using Flutter and native Kotlin. Unlike traditional wellbeing applications that measure screen time, MindScroll measures **the exact count of short-form content** (YouTube Shorts, Instagram Reels, Facebook Reels, and TikTok) that you consume each day.

The app uses Android's Accessibility Service to track swipes and new videos dynamically and overlays a real-time counter to promote conscious scrolling. It works entirely offline with no internet access, no accounts, and no third-party cloud databases—keeping your data private on your device.

---

## Architecture

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
