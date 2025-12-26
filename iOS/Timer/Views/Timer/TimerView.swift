import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    @Query private var logs: [HabitLog]
    @Query private var settingsArray: [AppSettings]

    @Bindable var timerVM: TimerViewModel
    @Bindable var habitsVM: HabitsViewModel

    @State private var showSettings = false
    @State private var showHabitPicker = false

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    private var timerHabits: [Habit] {
        habits.filter { $0.hasTimer }.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    if timerHabits.count > 1 {
                        Button {
                            showHabitPicker = true
                        } label: {
                            HStack(spacing: 8) {
                                if let habit = timerVM.selectedHabit {
                                    Image(systemName: habit.icon)
                                        .foregroundColor(habit.color)
                                    Text(habit.name)
                                        .foregroundColor(.white)
                                } else {
                                    Text("Timer wählen")
                                        .foregroundColor(.gray)
                                }
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else if let habit = timerVM.selectedHabit {
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
                    .padding(.bottom, 60)
            }
        }
        .sheet(isPresented: $showSettings) {
            TimerSettingsSheet(
                settings: settings,
                timerVM: timerVM
            )
        }
        .sheet(isPresented: $showHabitPicker) {
            habitPickerSheet
        }
        .onAppear {
            ensureSettings()
            selectInitialHabit()
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

    @ViewBuilder
    private var habitPickerSheet: some View {
        NavigationStack {
            List(timerHabits) { habit in
                Button {
                    timerVM.selectHabit(habit)
                    showHabitPicker = false
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: habit.icon)
                            .foregroundColor(habit.color)
                            .frame(width: 24)

                        Text(habit.name)
                            .foregroundColor(.primary)

                        Spacer()

                        if timerVM.selectedHabit?.id == habit.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Timer wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        showHabitPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func ensureSettings() {
        if settingsArray.isEmpty {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
        }
    }

    private func selectInitialHabit() {
        if timerVM.selectedHabit == nil, let first = timerHabits.first {
            timerVM.selectHabit(first)
        }
    }

    private func handleTimerCompleted(_ notification: Notification) {
        guard let habit = notification.object as? Habit else { return }

        // Trigger haptics/sound based on settings
        HapticsService.shared.trigger(for: settings.signal, sound: settings.sound, volume: settings.soundVolume)

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
