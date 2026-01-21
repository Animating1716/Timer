import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var timerVM = TimerViewModel()
    @State private var habitsVM = HabitsViewModel()
    @Query private var settingsArray: [AppSettings]

    private var settings: AppSettings? {
        settingsArray.first
    }

    var body: some View {
        HabitsView(habitsVM: habitsVM, timerVM: timerVM)
            .onAppear {
                timerVM.settings = settings
            }
            .onChange(of: settings) { _, newSettings in
                timerVM.settings = newSettings
            }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Habit.self, HabitLog.self, AppSettings.self])
        .preferredColorScheme(.dark)
}
