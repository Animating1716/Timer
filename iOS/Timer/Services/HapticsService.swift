import UIKit
import AVFoundation
import AudioToolbox

final class HapticsService {
    static let shared = HapticsService()

    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private var audioPlayer: AVAudioPlayer?

    private init() {
        impactGenerator.prepare()
        notificationGenerator.prepare()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
        }
    }

    func trigger(for type: SignalType, sound: TimerSound, volume: Double) {
        switch type {
        case .vibrationOnly:
            vibrate()
        case .soundAndVibration:
            vibrate()
            playSound(sound, volume: volume)
        case .soundOnly:
            playSound(sound, volume: volume)
        }
    }

    func vibrate() {
        notificationGenerator.notificationOccurred(.success)

        // Multiple vibrations for emphasis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.impactGenerator.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.impactGenerator.impactOccurred()
        }
    }

    func playSound(_ sound: TimerSound, volume: Double) {
        // Use system sound with volume
        // Note: System sounds respect device ringer volume
        // For more control, we play multiple times based on volume
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }

    /// Preview a sound (for settings)
    func previewSound(_ sound: TimerSound) {
        AudioServicesPlaySystemSound(sound.systemSoundID)
    }

    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func mediumTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
