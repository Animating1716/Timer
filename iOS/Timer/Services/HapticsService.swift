import UIKit
import AVFoundation
import CoreHaptics

final class HapticsService {
    static let shared = HapticsService()

    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private var halfPlayer: AVAudioPlayer?
    private var completePlayer: AVAudioPlayer?
    private var audioSessionReady = false
    private var hapticEngine: CHHapticEngine?

    private init() {
        impactGenerator.prepare()
        notificationGenerator.prepare()
        prepareAudioSession()
        prepareHapticsEngine()
        preloadSounds()
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
        if playHapticPattern(kind: .complete) {
            return
        }

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
        if playHapticPattern(kind: .halfway) {
            return
        }

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
        let player = (name == "ping_half") ? halfPlayer : completePlayer
        if let player = player {
            player.currentTime = 0
            player.play()
            return
        }

        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            AudioServicesPlaySystemSound(1007)
            return
        }
        do {
            let fallback = try AVAudioPlayer(contentsOf: url)
            fallback.prepareToPlay()
            fallback.volume = 1.0
            fallback.play()
        } catch {
            AudioServicesPlaySystemSound(1007)
            print("Could not play sound: \(error)")
        }
    }

    private func prepareAudioSession() {
        guard !audioSessionReady else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
            try? session.overrideOutputAudioPort(.speaker)
            audioSessionReady = true
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    private func preloadSounds() {
        halfPlayer = loadPlayer(named: "ping_half")
        completePlayer = loadPlayer(named: "ping_complete")
    }

    private func loadPlayer(named name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return nil }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 1.0
            return player
        } catch {
            print("Could not load sound \(name): \(error)")
            return nil
        }
    }

    private func prepareHapticsEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine setup failed: \(error)")
        }
    }

    private enum HapticKind {
        case halfway
        case complete
    }

    private func playHapticPattern(kind: HapticKind) -> Bool {
        guard let engine = hapticEngine else { return false }

        let intensity: Float = kind == .complete ? 1.0 : 0.7
        let sharpness: Float = kind == .complete ? 0.9 : 0.6

        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: kind == .complete ? 0.2 : 0.15
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: kind == .complete ? 0.45 : 0.3
            )
        ]

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            return true
        } catch {
            print("Haptic pattern failed: \(error)")
            return false
        }
    }
}
