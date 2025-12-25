import Foundation
import SwiftUI
import SwiftData
import Combine

@Observable
final class TimerViewModel {
    var selectedHabit: Habit?
    var timeRemaining: Int = 0
    var isRunning: Bool = false
    var isPaused: Bool = false

    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var enteredBackgroundTime: Date?

    var progress: Double {
        guard let habit = selectedHabit, habit.currentTimerDuration > 0 else { return 0 }
        return Double(habit.currentTimerDuration - timeRemaining) / Double(habit.currentTimerDuration)
    }

    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var totalTimeString: String {
        guard let habit = selectedHabit else { return "0min" }
        let minutes = habit.currentTimerDuration / 60
        return "\(minutes)min"
    }

    func selectHabit(_ habit: Habit) {
        stopTimer()
        selectedHabit = habit
        timeRemaining = habit.currentTimerDuration
    }

    func startTimer() {
        guard selectedHabit != nil else { return }
        isRunning = true
        isPaused = false
        startBackgroundTask()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isPaused = true
        isRunning = false
    }

    func resumeTimer() {
        guard isPaused else { return }
        startTimer()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        endBackgroundTask()
        if let habit = selectedHabit {
            timeRemaining = habit.currentTimerDuration
        }
    }

    func resetTimer(settings: AppSettings, modelContext: ModelContext) {
        stopTimer()
        if let habit = selectedHabit {
            habit.currentTimerDuration = 180 // Reset to 3 minutes
            timeRemaining = habit.currentTimerDuration
        }
        settings.totalTimerSeconds = 0
        try? modelContext.save()
    }

    private func tick() {
        guard timeRemaining > 0 else {
            timerCompleted()
            return
        }
        timeRemaining -= 1
    }

    private func timerCompleted() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        endBackgroundTask()

        // Will be handled by the view to update habit and trigger notification
        NotificationCenter.default.post(name: .timerCompleted, object: selectedHabit)
    }

    @objc private func appDidEnterBackground() {
        enteredBackgroundTime = Date()
        scheduleBackgroundNotification()
    }

    @objc private func appWillEnterForeground() {
        guard let enteredTime = enteredBackgroundTime, isRunning else { return }
        let elapsed = Int(Date().timeIntervalSince(enteredTime))
        timeRemaining = max(0, timeRemaining - elapsed)

        if timeRemaining == 0 {
            timerCompleted()
        }

        cancelBackgroundNotification()
        enteredBackgroundTime = nil
    }

    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    private func scheduleBackgroundNotification() {
        guard timeRemaining > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Timer beendet"
        content.body = selectedHabit?.name ?? "Dein Timer ist abgelaufen"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(timeRemaining),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "timer_complete",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelBackgroundNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["timer_complete"]
        )
    }
}

extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
}
