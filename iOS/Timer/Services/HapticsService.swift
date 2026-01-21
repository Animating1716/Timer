import UIKit
import AVFoundation

final class HapticsService {
    static let shared = HapticsService()

    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private var audioPlayer: AVAudioPlayer?

    private init() {
        impactGenerator.prepare()
        notificationGenerator.prepare()
    }

    func trigger(for type: SignalType) {
        switch type {
        case .vibrationOnly:
            vibrate()
        case .soundAndVibration:
            vibrate()
            playSound()
        case .soundOnly:
            playSound()
        }
    }

    func triggerHalfway(for type: SignalType) {
        switch type {
        case .vibrationOnly:
            halfwayHaptics()
        case .soundAndVibration:
            halfwayHaptics()
            playHalfwaySound()
        case .soundOnly:
            playHalfwaySound()
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

    private func halfwayHaptics() {
        notificationGenerator.notificationOccurred(.warning)
        impactGenerator.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.impactGenerator.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.impactGenerator.impactOccurred()
        }
    }

    func playSound() {
        // Use system sound
        AudioServicesPlaySystemSound(1007) // Standard notification sound

        // Alternative: Custom sound
        // playCustomSound(named: "timer_complete")
    }

    private func playHalfwaySound() {
        AudioServicesPlaySystemSound(1005)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            AudioServicesPlaySystemSound(1005)
        }
    }

    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func mediumTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func playCustomSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play sound: \(error)")
        }
    }
}
