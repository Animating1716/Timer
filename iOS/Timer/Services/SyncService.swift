import Foundation
import SwiftData

/// Service for syncing habit data to VPS
actor SyncService {
    static let shared = SyncService()

    // Configure these in your app
    private let syncURL: URL? = URL(string: "https://habits.yourdomain.com/sync") // Change this!
    private let apiKey: String = "your-api-key-here" // Change this!

    private var lastSyncDate: Date?
    private let syncDebounceInterval: TimeInterval = 30 // Don't sync more than once per 30 seconds

    private init() {}

    /// Sync current habit data to server
    func syncToServer(habits: [Habit], logs: [HabitLog]) async {
        // Debounce
        if let lastSync = lastSyncDate, Date().timeIntervalSince(lastSync) < syncDebounceInterval {
            return
        }

        guard let url = syncURL else {
            print("Sync URL not configured")
            return
        }

        // Build payload
        let today = Calendar.current.startOfDay(for: Date())
        let todayLogs = logs.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }

        let habitStatuses: [[String: Any]] = habits.map { habit in
            let log = todayLogs.first { $0.habitId == habit.id }
            let count = log?.count ?? 0
            return [
                "name": habit.name,
                "completed": count >= habit.dailyGoal,
                "count": count,
                "goal": habit.dailyGoal
            ]
        }

        let payload: [String: Any] = [
            "date": ISO8601DateFormatter().string(from: today),
            "habits": habitStatuses
        ]

        // Send request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                lastSyncDate = Date()
                print("Sync successful")
            } else {
                print("Sync failed with response: \(response)")
            }
        } catch {
            print("Sync error: \(error)")
        }
    }
}

// MARK: - SwiftData Integration

extension SyncService {
    /// Call this after any habit completion
    @MainActor
    static func syncAfterChange(modelContext: ModelContext) {
        Task {
            let habitDescriptor = FetchDescriptor<Habit>()
            let logDescriptor = FetchDescriptor<HabitLog>()

            guard let habits = try? modelContext.fetch(habitDescriptor),
                  let logs = try? modelContext.fetch(logDescriptor) else {
                return
            }

            await SyncService.shared.syncToServer(habits: habits, logs: logs)
        }
    }
}
