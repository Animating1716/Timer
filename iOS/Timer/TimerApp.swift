import SwiftUI
import SwiftData

@main
struct TimerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitLog.self,
            AppSettings.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none  // Local storage only for now
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .onAppear {
                    requestNotificationPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}
