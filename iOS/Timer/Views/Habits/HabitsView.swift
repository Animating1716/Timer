import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    @Query private var logs: [HabitLog]
    @Query private var settingsArray: [AppSettings]

    @Bindable var habitsVM: HabitsViewModel
    @Bindable var timerVM: TimerViewModel

    @State private var showNewHabit = false
    @State private var showSettings = false
    @State private var habitToEdit: Habit?
    @State private var showTimer = false
    @State private var stretchSession: StretchSession?

    private var settings: AppSettings? {
        settingsArray.first
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with filter and date
                headerView

                // Week calendar strip
                weekStripView
                    .padding(.top, 8)

                // Habit list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(habitsVM.filteredHabits(habits, logs: logs)) { habit in
                            let isCompleted = habitsVM.isCompleted(habit: habit, on: habitsVM.selectedDate, logs: logs)
                            HabitRowView(
                                habit: habit,
                                progress: habitsVM.getProgress(for: habit, on: habitsVM.selectedDate, logs: logs),
                                count: habitsVM.getLog(for: habit, on: habitsVM.selectedDate, logs: logs)?.count ?? 0,
                                isCompleted: isCompleted,
                                onTap: {
                                    handleHabitTap(habit)
                                },
                                onTimerTap: habit.hasTimer ? {
                                    timerVM.selectHabit(habit)
                                    showTimer = true
                                } : nil,
                                onStretchTap: habit.stretchEnabled ? {
                                    startStretch(for: habit)
                                } : nil
                            )
                            .onTapGesture {
                                habitToEdit = habit
                            }
                            .contextMenu {
                                Button {
                                    habitToEdit = habit
                                } label: {
                                    Label("Bearbeiten", systemImage: "pencil")
                                }

                                Button(role: .destructive) {
                                    habitsVM.deleteHabit(habit, logs: logs, modelContext: modelContext)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }

                Spacer()

                // Bottom bar
                bottomBar
            }
        }
        .sheet(isPresented: $showNewHabit) {
            NewHabitSheet(habits: habits)
        }
        .sheet(item: $habitToEdit) { habit in
            EditHabitSheet(habit: habit, habits: habits, logs: logs)
        }
        .sheet(isPresented: $showSettings) {
            HabitSettingsSheet()
        }
        .sheet(item: $stretchSession) { session in
            StretchSessionView(session: session, habitsVM: habitsVM)
        }
        .fullScreenCover(isPresented: $showTimer) {
            TimerView(timerVM: timerVM, habitsVM: habitsVM)
        }
        .onAppear {
            ensureSettings()
        }
    }

    @ViewBuilder
    private var headerView: some View {
        HStack {
            // Filter dropdown
            Menu {
                ForEach(HabitsViewModel.FilterType.allCases, id: \.self) { filter in
                    Button {
                        habitsVM.filterType = filter
                    } label: {
                        HStack {
                            Text(filter.rawValue)
                            if habitsVM.filterType == filter {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(habitsVM.filterType.rawValue)
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.3))
                .clipShape(Capsule())
            }

            Spacer()

            // Date display
            Text(habitsVM.displayDateString)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()

            // Placeholder for symmetry
            Color.clear
                .frame(width: 60, height: 32)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var weekStripView: some View {
        HStack(spacing: 8) {
            ForEach(habitsVM.weekDates, id: \.self) { date in
                VStack(spacing: 4) {
                    Text(date.weekday)
                        .font(.caption2)
                        .foregroundColor(.gray)

                    ZStack {
                        MiniProgressRing(
                            progress: habitsVM.dayProgress(for: date, habits: habits, logs: logs),
                            isSelected: Calendar.current.isDate(date, inSameDayAs: habitsVM.selectedDate)
                        )
                        .frame(width: 36, height: 36)

                        Text("\(date.dayOfMonth)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        habitsVM.selectedDate = date
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var bottomBar: some View {
        HStack(spacing: 0) {
            Spacer()

            // Add habit button
            Button {
                showNewHabit = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 48, height: 48)

                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }

            Spacer()

            // Settings button
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(white: 0.15))
        )
        .padding(.horizontal, 60)
        .padding(.bottom, 20)
    }

    private func handleHabitTap(_ habit: Habit) {
        if habit.dailyGoal > 1 {
            // Multi-count: increment
            habitsVM.incrementHabit(habit, on: habitsVM.selectedDate, logs: logs, modelContext: modelContext)
        } else {
            // Single count: toggle
            habitsVM.toggleHabit(habit, on: habitsVM.selectedDate, logs: logs, modelContext: modelContext)
        }
    }

    private func startStretch(for habit: Habit) {
        let count = max(1, habit.stretchExerciseCount)
        let catalog = settings?.stretchCatalog ?? .lifehack
        let selection = StretchCatalog.pickExercises(
            count: count,
            preferences: habit.stretchPreferences,
            catalog: catalog,
            cycleState: habit.stretchCycleState,
            frequencyMultiplier: habit.stretchFrequencyMultiplier
        )
        let exercises = selection.exercises
        habit.stretchCycleState = selection.cycleState
        try? modelContext.save()

        let duration = max(5, habit.stretchDuration)
        stretchSession = StretchSession(
            habit: habit,
            exercises: exercises,
            date: habitsVM.selectedDate,
            duration: duration
        )
    }

    private func ensureSettings() {
        if settingsArray.isEmpty {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            try? modelContext.save()
        }
    }
}

extension Notification.Name {
    static let switchToTimerTab = Notification.Name("switchToTimerTab")
}

#Preview {
    HabitsView(habitsVM: HabitsViewModel(), timerVM: TimerViewModel())
        .modelContainer(for: [Habit.self, HabitLog.self, AppSettings.self])
}

struct StretchSession: Identifiable {
    let id = UUID()
    let habit: Habit
    let exercises: [StretchExercise]
    let date: Date
    let duration: Int
}
