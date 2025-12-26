import Foundation
import SwiftData
import AudioToolbox

enum SignalType: String, Codable, CaseIterable {
    case vibrationOnly = "vibration"
    case soundAndVibration = "both"
    case soundOnly = "sound"

    var displayName: String {
        switch self {
        case .vibrationOnly: return "Nur Vibration"
        case .soundAndVibration: return "Ton + Vibration"
        case .soundOnly: return "Nur Ton"
        }
    }
}

enum TimerSound: String, Codable, CaseIterable {
    case chime = "chime"
    case bell = "bell"
    case horn = "horn"
    case electronic = "electronic"
    case gentle = "gentle"

    var displayName: String {
        switch self {
        case .chime: return "Glockenspiel"
        case .bell: return "Glocke"
        case .horn: return "Horn"
        case .electronic: return "Elektronisch"
        case .gentle: return "Sanft"
        }
    }

    // System Sound IDs (iOS built-in sounds)
    var systemSoundID: SystemSoundID {
        switch self {
        case .chime: return 1007      // Standard notification
        case .bell: return 1013       // Mail sent
        case .horn: return 1020       // Anticipate
        case .electronic: return 1016 // Tweet
        case .gentle: return 1004     // Health notification
        }
    }
}

@Model
final class AppSettings {
    var id: UUID
    var signalType: String // SignalType raw value
    var soundType: String // TimerSound raw value
    var soundVolume: Double // 0.0 to 1.0
    var selectedHabitIdForTimer: UUID?
    var totalTimerSeconds: Int // Gesamtzeit aller Timer Sessions
    var lastSyncDate: Date?

    init() {
        self.id = UUID()
        self.signalType = SignalType.soundAndVibration.rawValue
        self.soundType = TimerSound.chime.rawValue
        self.soundVolume = 0.7
        self.selectedHabitIdForTimer = nil
        self.totalTimerSeconds = 0
        self.lastSyncDate = nil
    }

    var signal: SignalType {
        get { SignalType(rawValue: signalType) ?? .soundAndVibration }
        set { signalType = newValue.rawValue }
    }

    var sound: TimerSound {
        get { TimerSound(rawValue: soundType) ?? .chime }
        set { soundType = newValue.rawValue }
    }
}
