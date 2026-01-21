import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var logs: [HabitLog]
    @Query private var settingsArray: [AppSettings]

    @Bindable var timerVM: TimerViewModel
    @Bindable var habitsVM: HabitsViewModel

    @State private var showSettings = false

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    // Close button
                    Button {
                        timerVM.stopTimer()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Habit name
                    if let habit = timerVM.selectedHabit {
                        HStack(spacing: 8) {
                            Image(systemName: habit.icon)
                                .foregroundColor(habit.color)
                            Text(habit.name)
                                .foregroundColor(.white)
                        }
                    }

                    Spacer()

                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // Timer Ring
                ZStack {
                    TimerRingView(
                        progress: timerVM.progress,
                        color: timerVM.selectedHabit?.color ?? .gray,
                        lineWidth: 6
                    )
                    .frame(width: 280, height: 280)

                    Text(timerVM.timeString)
                        .font(.system(size: 72, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                }

                // Total time
                Text("Gesamt: \(timerVM.totalTimeString)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 24)

                Spacer()

                // Play/Pause Button
                playPauseButton
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showSettings) {
            TimerSettingsSheet(
                settings: settings,
                timerVM: timerVM
            )
        }
        .onAppear {
            ensureSettings()
            timerVM.settings = settings
        }
        .onReceive(NotificationCenter.default.publisher(for: .timerCompleted)) { notification in
            handleTimerCompleted(notification)
        }
    }

    @ViewBuilder
    private var playPauseButton: some View {
        Button {
            if timerVM.isRunning {
                timerVM.pauseTimer()
            } else if timerVM.isPaused {
                timerVM.resumeTimer()
            } else {
                timerVM.startTimer()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 72, height: 72)

                Image(systemName: timerVM.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .offset(x: timerVM.isRunning ? 0 : 2)
            }
        }
        .disabled(timerVM.selectedHabit == nil)
        .opacity(timerVM.selectedHabit == nil ? 0.5 : 1)
    }

    private func ensureSettings() {
        if settingsArray.isEmpty {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
        }
    }

    private func handleTimerCompleted(_ notification: Notification) {
        guard let habit = notification.object as? Habit else { return }

        // Trigger haptics/sound based on settings
        HapticsService.shared.trigger(for: settings.signal)

        // Complete the habit
        habitsVM.completeTimerHabit(
            habit,
            timerSeconds: habit.currentTimerDuration,
            settings: settings,
            logs: logs,
            modelContext: modelContext
        )

        // Reset timer to new duration
        timerVM.timeRemaining = habit.currentTimerDuration
    }
}

#Preview {
    TimerView(timerVM: TimerViewModel(), habitsVM: HabitsViewModel())
        .modelContainer(for: [Habit.self, HabitLog.self, AppSettings.self])
}
