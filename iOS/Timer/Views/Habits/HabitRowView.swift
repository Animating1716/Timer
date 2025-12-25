import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let progress: Double // 0.0 to 1.0
    let count: Int
    let isCompleted: Bool
    let onTap: () -> Void
    let onTimerTap: (() -> Void)?

    private var backgroundColor: Color {
        habit.color.opacity(0.3)
    }

    private var completedColor: Color {
        habit.color.opacity(0.8)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Base background
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)

                // Progress fill
                RoundedRectangle(cornerRadius: 16)
                    .fill(completedColor)
                    .frame(width: geometry.size.width * progress)

                // Content
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(isCompleted ? habit.color : habit.color.opacity(0.5))
                            .frame(width: 40, height: 40)

                        Image(systemName: habit.icon)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }

                    // Title and progress
                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.name)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("\(count)/\(habit.dailyGoal)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    // Action buttons
                    HStack(spacing: 8) {
                        // Timer button (if habit has timer)
                        if habit.hasTimer, let timerAction = onTimerTap {
                            Button {
                                timerAction()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 36, height: 36)

                                    Image(systemName: "timer")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                            }
                        }

                        // Complete/Add button
                        Button {
                            HapticsService.shared.lightTap()
                            onTap()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? Color.green : Color.black.opacity(0.3))
                                    .frame(width: 36, height: 36)

                                Image(systemName: isCompleted ? "checkmark" : (habit.dailyGoal > 1 ? "plus" : "checkmark"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(isCompleted ? .white : (habit.dailyGoal > 1 ? .yellow : habit.color))
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .frame(height: 72)
    }
}

#Preview {
    VStack(spacing: 12) {
        HabitRowView(
            habit: {
                let h = Habit(name: "Shake", icon: "cup.and.saucer.fill", colorHex: "#808000", dailyGoal: 2)
                return h
            }(),
            progress: 0.5,
            count: 1,
            isCompleted: false,
            onTap: {},
            onTimerTap: nil
        )

        HabitRowView(
            habit: {
                let h = Habit(name: "Exercise", icon: "figure.run", colorHex: "#8B0000", dailyGoal: 1, hasTimer: true)
                return h
            }(),
            progress: 1.0,
            count: 1,
            isCompleted: true,
            onTap: {},
            onTimerTap: {}
        )

        HabitRowView(
            habit: {
                let h = Habit(name: "Meditation", icon: "figure.mind.and.body", colorHex: "#4A4A6A", dailyGoal: 1)
                return h
            }(),
            progress: 0,
            count: 0,
            isCompleted: false,
            onTap: {},
            onTimerTap: nil
        )
    }
    .padding()
    .background(Color.black)
}
