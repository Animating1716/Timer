import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var timerVM = TimerViewModel()
    @State private var habitsVM = HabitsViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView(timerVM: timerVM, habitsVM: habitsVM)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
                .tag(0)

            HabitsView(habitsVM: habitsVM, timerVM: timerVM)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Habits")
                }
                .tag(1)
        }
        .tint(.blue)
        .onReceive(NotificationCenter.default.publisher(for: .switchToTimerTab)) { _ in
            withAnimation {
                selectedTab = 0
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Habit.self, HabitLog.self, AppSettings.self])
        .preferredColorScheme(.dark)
}
