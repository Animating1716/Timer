import Foundation
import SwiftData

@Model
final class HabitLog {
    var id: UUID
    var habitId: UUID
    var date: Date // Normalized to start of day
    var count: Int // How many times completed today
    var timerSeconds: Int // Total timer seconds for today (for timer habits)
    var completedAt: Date? // When last marked complete

    init(habitId: UUID, date: Date = Date()) {
        self.id = UUID()
        self.habitId = habitId
        self.date = Calendar.current.startOfDay(for: date)
        self.count = 0
        self.timerSeconds = 0
        self.completedAt = nil
    }

    var isCompleted: Bool {
        count > 0
    }
}

// MARK: - Date Helpers
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    func daysBetween(_ other: Date) -> Int {
        Calendar.current.dateComponents([.day], from: self.startOfDay, to: other.startOfDay).day ?? 0
    }

    var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: self)
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    var displayString: String {
        if isToday {
            return "Heute"
        } else if isYesterday {
            return "Gestern"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d. MMMM"
            formatter.locale = Locale(identifier: "de_DE")
            return formatter.string(from: self)
        }
    }

    func daysOfWeek() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        for offset in -6...0 {
            if let date = calendar.date(byAdding: .day, value: offset, to: self) {
                dates.append(date)
            }
        }
        return dates
    }
}
