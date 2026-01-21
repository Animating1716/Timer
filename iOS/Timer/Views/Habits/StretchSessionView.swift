import SwiftUI
import SwiftData

struct StretchSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var logs: [HabitLog]
    @Query private var settingsArray: [AppSettings]

    let session: StretchSession
    @Bindable var habitsVM: HabitsViewModel

    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var isCompleted = false
    @State private var halfwayTriggered = false
    @State private var currentIndex = 0
    @State private var showFeedback = false

    init(session: StretchSession, habitsVM: HabitsViewModel) {
        self.session = session
        self.habitsVM = habitsVM
        let duration = max(5, session.duration)
        _timeRemaining = State(initialValue: duration)
    }

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    private var currentExercise: StretchExercise {
        let safeIndex = min(currentIndex, max(0, session.exercises.count - 1))
        return session.exercises[safeIndex]
    }

    private var progress: Double {
        guard currentDuration > 0 else { return 0 }
        return Double(currentDuration - timeRemaining) / Double(currentDuration)
    }

    private var currentDuration: Int {
        max(5, session.duration + (session.habit.stretchProgressive ? (session.habit.stretchIncrement * currentIndex) : 0))
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        stopTimer()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: session.habit.icon)
                            .foregroundColor(session.habit.color)
                        Text(session.habit.name)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Color.clear
                        .frame(width: 28, height: 28)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                VStack(spacing: 12) {
                    Text(timeString)
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()
                        .padding(.top, 16)

                    StretchProgressBar(
                        progress: progress,
                        color: progress >= 0.5 ? .green : session.habit.color
                    )
                    .frame(height: 8)
                    .padding(.horizontal, 32)

                    if !isCompleted {
                        Text(progress >= 0.5 ? "Halbzeit erreicht" : "Läuft ...")
                            .font(.subheadline)
                            .foregroundColor(progress >= 0.5 ? .green : .gray)
                    } else {
                        Text("Fertig!")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        if let imageName = currentExercise.imageName {
                            Image(imageName)
                                .resizable()
                                .renderingMode(.original)
                                .colorInvert()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                        } else {
                            Image(systemName: currentExercise.symbolName)
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                        }

                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 2)
                            .frame(width: 260, height: 260)
                    }

                    Text(currentExercise.name)
                        .font(.title2)
                        .foregroundColor(.white)

                    Text(currentExercise.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    if session.exercises.count > 1 {
                        Text("Übung \(currentIndex + 1) von \(session.exercises.count)")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }

                Spacer()

                Button {
                    if isCompleted {
                        dismiss()
                    } else {
                        stopTimer()
                        dismiss()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.green : Color.blue)
                            .frame(width: 72, height: 72)

                        Image(systemName: isCompleted ? "checkmark" : "stop.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            ensureSettings()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showFeedback) {
            StretchFeedbackView(
                habit: session.habit,
                exercises: session.exercises
            ) {
                dismiss()
            }
        }
    }

    private func startTimer() {
        guard !session.exercises.isEmpty else { return }
        guard timer == nil, timeRemaining > 0, !isCompleted else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        if timeRemaining <= 1 {
            timeRemaining = 0
            completeSession()
            return
        }

        timeRemaining -= 1

        if !halfwayTriggered && timeRemaining == currentDuration / 2 {
            halfwayTriggered = true
            HapticsService.shared.trigger(for: settings.signal)
        }
    }

    private func completeSession() {
        guard !isCompleted else { return }
        stopTimer()
        timeRemaining = 0

        HapticsService.shared.trigger(for: settings.signal)

        if currentIndex < session.exercises.count - 1 {
            currentIndex += 1
            halfwayTriggered = false
            timeRemaining = currentDuration
            startTimer()
            return
        }

        isCompleted = true
        habitsVM.incrementHabit(session.habit, on: session.date, logs: logs, modelContext: modelContext)

        if session.habit.stretchProgressive {
            session.habit.stretchDuration = currentDuration
        }

        try? modelContext.save()
        showFeedback = true
    }

    private func ensureSettings() {
        if settingsArray.isEmpty {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
        }
    }
}

private struct StretchProgressBar: View {
    let progress: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(0, min(1, progress)) * proxy.size.width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))

                Capsule()
                    .fill(color)
                    .frame(width: width)

                Rectangle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 2)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
    }
}

private struct StretchFeedbackView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var habit: Habit
    let exercises: [StretchExercise]
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(exercises) { exercise in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.05))
                                    .frame(width: 36, height: 36)

                                if let imageName = exercise.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .renderingMode(.original)
                                        .colorInvert()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                } else {
                                    Image(systemName: exercise.symbolName)
                                        .font(.system(size: 18))
                                        .foregroundColor(.primary)
                                }
                            }

                            Text(exercise.name)
                                .foregroundColor(.primary)

                            Spacer()

                            HStack(spacing: 12) {
                                let weight = habit.stretchPreference(for: exercise.id)

                                Button {
                                    updatePreference(for: exercise, delta: -1)
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 18))
                                }
                                .disabled(weight <= Habit.stretchPreferenceMin)
                                .opacity(weight <= Habit.stretchPreferenceMin ? 0.3 : 1)

                                Button {
                                    updatePreference(for: exercise, delta: 1)
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 18))
                                }
                                .disabled(weight >= Habit.stretchPreferenceMax)
                                .opacity(weight >= Habit.stretchPreferenceMax ? 0.3 : 1)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        try? modelContext.save()
                        dismiss()
                        onDone()
                    }
                }
            }
        }
    }

    private func updatePreference(for exercise: StretchExercise, delta: Int) {
        habit.updateStretchPreference(for: exercise.id, delta: delta)
        try? modelContext.save()
    }
}

#Preview {
    let habit = Habit(name: "Dehnen", icon: "figure.mind.and.body", colorHex: "#4A4A6A")
    let session = StretchSession(
        habit: habit,
        exercises: [StretchCatalog.exercises[0]],
        date: Date(),
        duration: 30
    )

    StretchSessionView(session: session, habitsVM: HabitsViewModel())
        .modelContainer(for: [Habit.self, HabitLog.self, AppSettings.self])
}
