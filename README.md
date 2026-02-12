# 🧺 WashWatch

> **Ironing out the waiting game.** > *Participant at [Build for Campus Hackathon 2026]*
> 
## 🧐 The Problem
Living in a university hostel comes with one universal struggle: **The Laundry War.** We've all been there:
* 😤 Hauling a heavy basket down 4 flights of stairs, only to find **zero** machines available.
* 😡 Waiting for a "finished" machine because the owner hasn't collected their clothes.
* 🤬 Awkward group chat messages like *"Hi, whoever touched my laundry..."*

**WashWatch** was built to end this friction. We turn a chaotic, manual chore into a streamlined, digital experience.

## 🚀 What is WashWatch?
WashWatch is a cross-platform mobile application (built with **Flutter**) that serves as a digital command centre for communal laundry rooms. It connects students to machines in real-time, enforcing social etiquette through smart design.

### Key Features
* **👀 Live Machine Status:** See exactly which washers and dryers are free *before* you leave your room.
* **✋ The "Chope" System:** Reserve a machine 5 minutes before a cycle ends. No more queue jumping.
* **📲 Scan & Go:** Integrated QR code scanning to verify presence and start cycles.
* **🔔 Auto-Notifications:** Get a "Laundry Done" ping instantly. If you don't move it, the app lets the queue know!

## 🛠️ Tech Stack
* **Frontend:** [Flutter](https://flutter.dev/) (Dart) - for a seamless iOS & Android experience.
* **Integration:** Mocked integration with LG Smart Solution API (Simulated IoT data).
* **Backend:** [Firebase/Node.js - *edit based on what you actually used*]

## 💻 Getting Started
To run this project locally, you will need the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

1.  **Clone the repo**
    ```bash
    git clone [https://github.com/JustLikeChuu/WashWatch.git](https://github.com/JustLikeChuu/WashWatch.git)
    cd WashWatch
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the app**
    ```bash
    # For Android
    flutter run

    # For iOS (Mac only)
    cd ios && pod install && cd ..
    flutter run
    ```

## 💡 How It Works
1.  **Check:** Open the app to view the live dashboard of your hostel block.
2.  **Reserve:** Tap "Chope" on a machine that is finishing soon.
3.  **Scan:** Arrive at the laundry room and scan the machine's QR code to unlock your slot.
4.  **Relax:** Go back to your room. We'll ping you when it's time to transfer to the dryer.

## 👥 The Team
* **[Nicholas Wee]** - *Group Leader*
* **[Ethan Ng]**
* **[Ang Ke Jin]**
* **[Ryan Ngo]**
* **[Ezra]**

---
*Built with 💙 and ☕ for [Build for Campus 2026].*
