import Foundation
import SwiftUI
import SwiftData

@Model
final class Habit {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "circle.fill"
    var colorHex: String = "#FF6B6B"
    var dailyGoal: Int = 1
    var hasTimer: Bool = false
    var timerIncrement: Int = 10
    var currentTimerDuration: Int = 180
    var linkedToExercise: Bool = false
    var stretchDuration: Int = 30
    var stretchIncrement: Int = 5
    var stretchProgressive: Bool = false
    var stretchExerciseCount: Int = 1
    var stretchPreferenceJSON: String = "{}"
    var stretchCycleOrderJSON: String = "[]"
    var lastStretchIndex: Int = -1
    var sortOrder: Int = 0
    var createdAt: Date = Date()

    init(
        name: String,
        icon: String = "circle.fill",
        colorHex: String = "#FF6B6B",
        dailyGoal: Int = 1,
        hasTimer: Bool = false,
        timerIncrement: Int = 10,
        currentTimerDuration: Int = 180,
        stretchEnabled: Bool = false,
        stretchDuration: Int = 30,
        stretchIncrement: Int = 5,
        stretchProgressive: Bool = false,
        stretchExerciseCount: Int = 1,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.dailyGoal = dailyGoal
        self.hasTimer = hasTimer
        self.timerIncrement = timerIncrement
        self.currentTimerDuration = currentTimerDuration
        self.linkedToExercise = stretchEnabled
        self.stretchDuration = stretchDuration
        self.stretchIncrement = stretchIncrement
        self.stretchProgressive = stretchProgressive
        self.stretchExerciseCount = stretchExerciseCount
        self.stretchPreferenceJSON = "{}"
        self.stretchCycleOrderJSON = "[]"
        self.lastStretchIndex = -1
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }

    var color: Color {
        Color(hex: colorHex) ?? .red
    }

    var stretchEnabled: Bool {
        get { linkedToExercise }
        set { linkedToExercise = newValue }
    }

    static let stretchPreferenceMin = -4
    static let stretchPreferenceMax = 4

    var stretchPreferences: [String: Int] {
        get {
            guard let data = stretchPreferenceJSON.data(using: .utf8) else { return [:] }
            let decoded = (try? JSONSerialization.jsonObject(with: data)) as? [String: Int]
            return decoded ?? [:]
        }
        set {
            guard let data = try? JSONSerialization.data(withJSONObject: newValue) else {
                stretchPreferenceJSON = "{}"
                return
            }
            stretchPreferenceJSON = String(data: data, encoding: .utf8) ?? "{}"
        }
    }

    var stretchCycleOrder: [String] {
        get {
            guard let data = stretchCycleOrderJSON.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue),
                  let json = String(data: data, encoding: .utf8) else {
                stretchCycleOrderJSON = "[]"
                return
            }
            stretchCycleOrderJSON = json
        }
    }

    func stretchPreference(for exerciseId: String) -> Int {
        stretchPreferences[exerciseId] ?? 0
    }

    func updateStretchPreference(for exerciseId: String, delta: Int) {
        var prefs = stretchPreferences
        let current = prefs[exerciseId] ?? 0
        let updated = max(Habit.stretchPreferenceMin, min(Habit.stretchPreferenceMax, current + delta))
        prefs[exerciseId] = updated
        stretchPreferences = prefs
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#FF6B6B" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Preset Colors
extension Habit {
    static let presetColors: [(name: String, hex: String)] = [
        ("Olive", "#808000"),
        ("Red", "#8B0000"),
        ("Purple", "#4A4A6A"),
        ("Brown", "#6B4423"),
        ("Blue", "#4A90D9"),
        ("Green", "#2D8B4A"),
        ("Orange", "#D97B4A"),
        ("Pink", "#D94A8B")
    ]

    static let presetIcons: [String] = [
        "cup.and.saucer.fill",
        "figure.run",
        "figure.mind.and.body",
        "figure.cooldown",
        "brain.head.profile",
        "book.fill",
        "drop.fill",
        "bed.double.fill",
        "sunrise.fill",
        "moon.fill",
        "leaf.fill",
        "heart.fill",
        "star.fill",
        "bolt.fill"
    ]
}
