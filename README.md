# HackerNewsIcon 🚀

A **macOS menu bar app** that monitors **Hacker News** for top posts.  
Displays trending articles and **notifies you when a new post reaches your set score threshold**.

---

## 📌 Features
✅ **Live Hacker News Updates** – Fetches the latest trending posts every minute.  
✅ **Customizable Score Threshold** – Set the minimum points required for notifications. (Default is 250).
✅ **Custom Notifications** – Choose between system sounds or a custom hacker mp3.
✅ **Quick Access** – Open Hacker News articles directly from the menu bar.  
✅ **Minimalist & Lightweight** – Runs in the background.  

---

## 📷 Screenshot

---

## 🔧 Installation
1. **Download the `.app` file** from [Releases](https://github.com/your-username/HackerNewsIcon/releases).  
2. **Move the app** to `/Applications`.  
3. **Run it** and allow permissions if prompted.  

---

## ⚙️ Preferences
- **Set the Minimum Score Threshold** *(e.g., Only notify if a post has 500+ points)*
- **Choose a Notification Sound**
  - Ping
  - Submarine
  - Morse
  - **Custom MP3** *(Default: "All Your Base" MP3)*
  - No Sound *(Silent Mode)*

---

## 🚀 How to Use
1. **Click the menu bar icon** → View trending Hacker News posts.
2. **Click a post** → Opens the Hacker News discussion.
3. **Preferences** → Customize notifications and sound settings.

---

## 🛠️ Building from Source
### **🔹 Prerequisites**
- **macOS 12+**
- **Xcode 14+**
- **Swift 5**
- **AVFoundation (for sound playback)**

### **🔹 Clone & Run**
```sh
git clone https://github.com/your-username/HackerNewsIcon.git
cd HackerNewsIcon
open HackerNewsIcon.xcodeproj

