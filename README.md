# HackerNewsIcon

A **macOS menu bar app** that monitors **Hacker News** for top posts.  
Displays trending articles and **notifies you when a new post reaches your set score threshold**.

---

## Features
- **Live Hacker News Updates** – Fetches the latest trending posts every minute.  
- **Customizable Score Threshold** – Set the minimum points required for notifications. (Default is 250).
- **Custom Sounds** – Choose between system sounds or a custom hacker mp3. 
- **Visual Notification** = The notification icon also flashes momentarily when it gets a new post that meets your threshold.
- **Quick Access** – Open Hacker News articles directly from the menu bar.  
- **Minimalist & Lightweight** – Runs in the background.  

---

## Screenshot
<img width="364" alt="screen" src="https://github.com/user-attachments/assets/5d1808bb-b29c-4724-aa2f-987768127d3a" />


---

## Installation
1. **Download the `.app` file** from [Releases](https://github.com/rfaile313/HackerNewsIcon/releases/).  
2. **Move the app** to `/Applications`.  
3. **Run it** and allow permissions if prompted.  

---

## ⚙Preferences
- **Set the Minimum Score Threshold** *(e.g., Only notify if a post has 500+ points)* 
- **Choose a Notification Sound**
  - Ping (Default)
  - Submarine
  - Morse
  - **Custom MP3** *("All Your Base" MP3)*
  - No Sound *(Silent Mode)*

---

## How to Use
1. **Click the menu bar icon** → View trending Hacker News posts.
2. **Click a post** → Opens the Hacker News discussion.
3. **Preferences** → Customize notifications and sound settings.

---

## Building from Source
### **Prerequisites**
- **macOS 12+**
- **Xcode 14+**
- **Swift 5**
- **AVFoundation (for sound playback)**

### **Clone & Run**
```sh
git clone https://github.com/rfaile313/HackerNewsIcon.git
cd HackerNewsIcon
open HackerNewsIcon.xcodeproj
```

Feel free to let me know if you see anything weird in this readme, app, or code. A lot of it was generated with AI [as an experiment](https://rudyfaile.com/2025/03/09/claude-kind-of-sucks/). 
