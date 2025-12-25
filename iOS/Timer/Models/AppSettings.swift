import Foundation
import SwiftData

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

@Model
final class AppSettings {
    var id: UUID
    var signalType: String // SignalType raw value
    var selectedHabitIdForTimer: UUID?
    var totalTimerSeconds: Int // Gesamtzeit aller Timer Sessions
    var lastSyncDate: Date?

    init() {
        self.id = UUID()
        self.signalType = SignalType.soundAndVibration.rawValue
        self.selectedHabitIdForTimer = nil
        self.totalTimerSeconds = 0
        self.lastSyncDate = nil
    }

    var signal: SignalType {
        get { SignalType(rawValue: signalType) ?? .soundAndVibration }
        set { signalType = newValue.rawValue }
    }
}
