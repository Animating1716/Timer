import Foundation
import CloudKit

/// Service for syncing habit data with CloudKit for MCP server access
/// This creates public records that the MCP server can read
final class CloudKitService {
    static let shared = CloudKitService()

    private let container = CKContainer(identifier: "iCloud.com.joshua.HabitTimer")
    private var publicDatabase: CKDatabase { container.publicCloudDatabase }

    private init() {}

    // MARK: - Sync Habits Status

    /// Updates the public CloudKit database with today's habit status
    /// This is what the MCP server will read
    func syncTodayStatus(habits: [(name: String, completed: Bool, count: Int, goal: Int)]) async {
        let recordID = CKRecord.ID(recordName: "today_status")

        do {
            // Try to fetch existing record
            let existingRecord = try? await publicDatabase.record(for: recordID)
            let record = existingRecord ?? CKRecord(recordType: "DailyStatus", recordID: recordID)

            // Update record
            record["date"] = ISO8601DateFormatter().string(from: Date()) as CKRecordValue
            record["habits"] = try JSONEncoder().encode(habits.map { HabitStatus(name: $0.name, completed: $0.completed, count: $0.count, goal: $0.goal) }) as CKRecordValue
            record["lastUpdated"] = Date() as CKRecordValue

            // Save
            try await publicDatabase.save(record)
            print("CloudKit sync successful")
        } catch {
            print("CloudKit sync error: \(error)")
        }
    }

    /// Fetches today's status (for testing)
    func fetchTodayStatus() async -> [HabitStatus]? {
        let recordID = CKRecord.ID(recordName: "today_status")

        do {
            let record = try await publicDatabase.record(for: recordID)
            if let data = record["habits"] as? Data {
                return try JSONDecoder().decode([HabitStatus].self, from: data)
            }
        } catch {
            print("CloudKit fetch error: \(error)")
        }
        return nil
    }
}

struct HabitStatus: Codable {
    let name: String
    let completed: Bool
    let count: Int
    let goal: Int
}

// MARK: - Extension for syncing from SwiftData

import SwiftData

extension CloudKitService {
    @MainActor
    func syncFromSwiftData(modelContext: ModelContext) async {
        let habitDescriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder)])
        let logDescriptor = FetchDescriptor<HabitLog>()

        guard let habits = try? modelContext.fetch(habitDescriptor),
              let logs = try? modelContext.fetch(logDescriptor) else {
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let todayLogs = logs.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }

        let statusList: [(name: String, completed: Bool, count: Int, goal: Int)] = habits.map { habit in
            let log = todayLogs.first { $0.habitId == habit.id }
            let count = log?.count ?? 0
            return (
                name: habit.name,
                completed: count >= habit.dailyGoal,
                count: count,
                goal: habit.dailyGoal
            )
        }

        await syncTodayStatus(habits: statusList)
    }
}
