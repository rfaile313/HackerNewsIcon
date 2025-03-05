import Cocoa
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menu: NSMenu?
    var topPosts: [(title: String, url: String, score: Int)] = [] // Store last 5 posts
    let hackerNewsAPI = "https://hacker-news.firebaseio.com/v0/topstories.json"
    var preferencesWindow: PreferencesWindowController?
    var audioPlayer: AVAudioPlayer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory) // Prevents Dock icon
        setupMenuBar()
        fetchTopHNPosts() // Initial check when app launches
        Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(fetchTopHNPosts), userInfo: nil, repeats: true)
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "newspaper.fill", accessibilityDescription: "Hacker News")
            button.image?.isTemplate = true // Tries to ensure visibility in dark mode
            button.action = #selector(refreshMenu)
            button.target = self
        }

        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: "Fetching...", action: nil, keyEquivalent: ""))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: ","))
        menu?.addItem(NSMenuItem(title: "Refresh", action: #selector(fetchTopHNPosts), keyEquivalent: "r"))
        menu?.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func fetchTopHNPosts() {
        guard let url = URL(string: hackerNewsAPI) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let postIDs = try JSONDecoder().decode([Int].self, from: data).prefix(50) // Get first 50 posts
                self.fetchPostDetails(for: Array(postIDs))
            } catch {
                print("Error decoding Hacker News API response: \(error)")
            }
        }
        task.resume()
    }

    func fetchPostDetails(for ids: [Int]) {
        let group = DispatchGroup()
        var newPosts: [(title: String, url: String, score: Int)] = []

        let minScore = UserDefaults.standard.integer(forKey: "HNScoreThreshold")
        // default to 250
        if minScore == 0 { UserDefaults.standard.set(250, forKey: "HNScoreThreshold") }

        for id in ids {
            group.enter()
            let postURL = "https://hacker-news.firebaseio.com/v0/item/\(id).json"

            guard let url = URL(string: postURL) else {
                group.leave()
                continue
            }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                guard let data = data, error == nil else { return }

                do {
                    let post = try JSONDecoder().decode(HNPost.self, from: data)
                    if post.score >= minScore {
                        newPosts.append((title: post.title, url: "https://news.ycombinator.com/item?id=\(post.id)", score: post.score))
                    }
                } catch {
                    print("Error decoding post: \(error)")
                }
            }
            task.resume()
        }

        group.notify(queue: .main) {
            self.updateMenu(with: newPosts)
        }
    }

    func updateMenu(with newPosts: [(title: String, url: String, score: Int)]) {
        let filteredPosts = newPosts.prefix(5) // Keep only the last 5 posts

        // Check if there's a new post
        if !filteredPosts.isEmpty && (topPosts.isEmpty || filteredPosts[0].title != topPosts.first?.title) {
            notifyNewPost()
        }

        // Update stored posts
        topPosts = filteredPosts.map { ($0.title, $0.url, $0.score) }

        // Refresh
        refreshMenu()
    }

    @objc func refreshMenu() {
        menu?.removeAllItems()

        if topPosts.isEmpty {
            menu?.addItem(NSMenuItem(title: "No trending posts", action: nil, keyEquivalent: ""))
        } else {
            for post in topPosts {
                let menuItem = NSMenuItem(title: "(\(post.score)★) \(post.title)", action: #selector(openPost), keyEquivalent: "")
                menuItem.representedObject = post.url
                menuItem.target = self
                menu?.addItem(menuItem)
            }
        }

        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: "Preferences", action: #selector(openPreferences), keyEquivalent: ","))
        menu?.addItem(NSMenuItem(title: "Manual Refresh", action: #selector(fetchTopHNPosts), keyEquivalent: "r"))
        menu?.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func openPost(_ sender: NSMenuItem) {
        if let urlString = sender.representedObject as? String, let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    func notifyNewPost() {
        let selectedSound = UserDefaults.standard.string(forKey: "HNNotificationSound") ?? "Ping"

        if selectedSound == "No Sound" {
            print("Notifications are muted.")
        } else if selectedSound == "All Your Base (MP3)" {
            // Play custom MP3 sound
            if let soundURL = Bundle.main.url(forResource: "all-your-base", withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.play()
                } catch {
                    print("Failed to play custom MP3: \(error)")
                }
            } else {
                print("Custom MP3 file not found!")
            }
        } else {
            // Play system sound
            NSSound(named: selectedSound)?.play()
        }

        // Flash the icon
        DispatchQueue.main.async {
            self.statusItem?.button?.image = NSImage(systemSymbolName: "bell.fill", accessibilityDescription: "New Post!")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.statusItem?.button?.image = NSImage(systemSymbolName: "exclamationmark.circle.fill", accessibilityDescription: "New Post!")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.statusItem?.button?.image = NSImage(systemSymbolName: "newspaper.fill", accessibilityDescription: "Hacker News")
            }
        }
    }


    @objc func openPreferences() {
        if preferencesWindow == nil {
            preferencesWindow = PreferencesWindowController()
        }
        preferencesWindow?.showWindow(nil)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// Preferences Window
class PreferencesWindowController: NSWindowController, NSTextFieldDelegate {
    var thresholdTextField: NSTextField!
    var soundDropdown: NSPopUpButton!
    
    let availableSounds = ["No Sound", "Ping", "Submarine", "Sosumi", "Morse", "All Your Base (MP3)"]

    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "HN Icon Preferences"
        window.level = .floating 
        window.center()
        super.init(window: window)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setupUI() {
        guard let window = self.window else { return }

        let contentView = NSView(frame: window.contentView!.frame)
        window.contentView = contentView

        // Label for threshold
        let label = NSTextField(labelWithString: "Min Score Threshold:")
        label.frame = NSRect(x: 20, y: 140, width: 200, height: 20)
        contentView.addSubview(label)

        // Text field for score threshold
        thresholdTextField = NSTextField(frame: NSRect(x: 20, y: 110, width: 100, height: 24))
        thresholdTextField.stringValue = "\(UserDefaults.standard.integer(forKey: "HNScoreThreshold"))"
        thresholdTextField.delegate = self
        contentView.addSubview(thresholdTextField)

        // Dropdown for sound selection
        let soundLabel = NSTextField(labelWithString: "Notification Sound:")
        soundLabel.frame = NSRect(x: 20, y: 80, width: 200, height: 20)
        contentView.addSubview(soundLabel)

        soundDropdown = NSPopUpButton(frame: NSRect(x: 20, y: 50, width: 200, height: 24), pullsDown: false)
        soundDropdown.addItems(withTitles: availableSounds)

        // Default to saved sound, or "Ping" if nothing is saved
        let savedSound = UserDefaults.standard.string(forKey: "HNNotificationSound") ?? "Ping"
        if availableSounds.contains(savedSound) {
            soundDropdown.selectItem(withTitle: savedSound)
        }
        
        contentView.addSubview(soundDropdown)

        // Save Button (Below Dropdown)
        let saveButton = NSButton(title: "Save", target: self, action: #selector(savePreferences))
        saveButton.frame = NSRect(x: 100, y: 10, width: 100, height: 30)
        contentView.addSubview(saveButton)
    }

    @objc func savePreferences() {
        // Save Score Threshold
        if let value = Int(thresholdTextField.stringValue) {
            UserDefaults.standard.set(value, forKey: "HNScoreThreshold")
        }

        // Save Selected Sound
        if let selectedSound = soundDropdown.selectedItem?.title {
            UserDefaults.standard.set(selectedSound, forKey: "HNNotificationSound")
        }

        window?.close()
    }
}

// Hacker News Post Model
struct HNPost: Codable {
    let id: Int
    let title: String
    let url: String?
    let score: Int
}
