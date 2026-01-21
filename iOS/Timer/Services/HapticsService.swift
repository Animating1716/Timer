import UIKit
import AVFoundation

final class HapticsService {
    static let shared = HapticsService()

    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private var audioPlayer: AVAudioPlayer?
    private var audioSessionReady = false

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
        impactGenerator.impactOccurred(intensity: 1.0)

        // Extra pulses for stronger feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.impactGenerator.impactOccurred(intensity: 0.9)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.impactGenerator.impactOccurred(intensity: 0.9)
        }
    }

    private func halfwayHaptics() {
        notificationGenerator.notificationOccurred(.warning)
        impactGenerator.impactOccurred(intensity: 0.8)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.impactGenerator.impactOccurred(intensity: 0.8)
        }
    }

    func playSound() {
        playCustomSound(named: "ping_complete")
    }

    private func playHalfwaySound() {
        playCustomSound(named: "ping_half")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            self?.playCustomSound(named: "ping_half")
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
        prepareAudioSession()
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            AudioServicesPlaySystemSound(1007)
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            AudioServicesPlaySystemSound(1007)
            print("Could not play sound: \(error)")
        }
    }

    private func prepareAudioSession() {
        guard !audioSessionReady else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            audioSessionReady = true
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
}
