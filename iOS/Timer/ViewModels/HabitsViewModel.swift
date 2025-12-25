import Foundation
import SwiftUI
import SwiftData

@Observable
final class HabitsViewModel {
    var selectedDate: Date = Date()
    var filterType: FilterType = .all

    enum FilterType: String, CaseIterable {
        case all = "Alle"
        case pending = "Offen"
        case completed = "Erledigt"
    }

    var weekDates: [Date] {
        selectedDate.daysOfWeek()
    }

    var displayDateString: String {
        selectedDate.displayString
    }

    func getLog(for habit: Habit, on date: Date, logs: [HabitLog]) -> HabitLog? {
        logs.first { log in
            log.habitId == habit.id &&
            Calendar.current.isDate(log.date, inSameDayAs: date)
        }
    }

    func getProgress(for habit: Habit, on date: Date, logs: [HabitLog]) -> Double {
        guard let log = getLog(for: habit, on: date, logs: logs) else { return 0 }
        return min(1.0, Double(log.count) / Double(habit.dailyGoal))
    }

    func isCompleted(habit: Habit, on date: Date, logs: [HabitLog]) -> Bool {
        guard let log = getLog(for: habit, on: date, logs: logs) else { return false }
        return log.count >= habit.dailyGoal
    }

    func incrementHabit(_ habit: Habit, on date: Date, logs: [HabitLog], modelContext: ModelContext) {
        if let log = getLog(for: habit, on: date, logs: logs) {
            log.count += 1
            log.completedAt = Date()
        } else {
            let newLog = HabitLog(habitId: habit.id, date: date)
            newLog.count = 1
            newLog.completedAt = Date()
            modelContext.insert(newLog)
        }
        try? modelContext.save()
    }

    func toggleHabit(_ habit: Habit, on date: Date, logs: [HabitLog], modelContext: ModelContext) {
        if let log = getLog(for: habit, on: date, logs: logs) {
            if log.count >= habit.dailyGoal {
                // Reset if already complete
                log.count = 0
                log.completedAt = nil
            } else {
                // Complete
                log.count = habit.dailyGoal
                log.completedAt = Date()
            }
        } else {
            let newLog = HabitLog(habitId: habit.id, date: date)
            newLog.count = habit.dailyGoal
            newLog.completedAt = Date()
            modelContext.insert(newLog)
        }
        try? modelContext.save()
    }

    func completeTimerHabit(_ habit: Habit, timerSeconds: Int, settings: AppSettings, logs: [HabitLog], modelContext: ModelContext) {
        let today = Date()

        if let log = getLog(for: habit, on: today, logs: logs) {
            log.count += 1
            log.timerSeconds += timerSeconds
            log.completedAt = Date()
        } else {
            let newLog = HabitLog(habitId: habit.id, date: today)
            newLog.count = 1
            newLog.timerSeconds = timerSeconds
            newLog.completedAt = Date()
            modelContext.insert(newLog)
        }

        // Update habit's timer duration for next time
        habit.currentTimerDuration += habit.timerIncrement

        // Update total timer seconds
        settings.totalTimerSeconds += timerSeconds

        try? modelContext.save()
    }

    func deleteHabit(_ habit: Habit, logs: [HabitLog], modelContext: ModelContext) {
        // Delete all logs for this habit
        for log in logs where log.habitId == habit.id {
            modelContext.delete(log)
        }
        modelContext.delete(habit)
        try? modelContext.save()
    }

    func filteredHabits(_ habits: [Habit], logs: [HabitLog]) -> [Habit] {
        switch filterType {
        case .all:
            return habits.sorted { $0.sortOrder < $1.sortOrder }
        case .pending:
            return habits.filter { !isCompleted(habit: $0, on: selectedDate, logs: logs) }
                .sorted { $0.sortOrder < $1.sortOrder }
        case .completed:
            return habits.filter { isCompleted(habit: $0, on: selectedDate, logs: logs) }
                .sorted { $0.sortOrder < $1.sortOrder }
        }
    }

    func dayProgress(for date: Date, habits: [Habit], logs: [HabitLog]) -> Double {
        guard !habits.isEmpty else { return 0 }
        let completed = habits.filter { isCompleted(habit: $0, on: date, logs: logs) }.count
        return Double(completed) / Double(habits.count)
    }
}
