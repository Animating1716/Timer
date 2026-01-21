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
    var id: UUID = UUID()
    var signalType: String = SignalType.soundAndVibration.rawValue
    var halfwaySignalEnabled: Bool = true
    var selectedHabitIdForTimer: UUID?
    var totalTimerSeconds: Int = 0
    var lastSyncDate: Date?

    init() {
        self.id = UUID()
        self.signalType = SignalType.soundAndVibration.rawValue
        self.halfwaySignalEnabled = true
        self.selectedHabitIdForTimer = nil
        self.totalTimerSeconds = 0
        self.lastSyncDate = nil
    }

    var signal: SignalType {
        get { SignalType(rawValue: signalType) ?? .soundAndVibration }
        set { signalType = newValue.rawValue }
    }
}
