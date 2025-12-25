import SwiftUI
import SwiftData

struct NewHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let habits: [Habit]

    @State private var name = ""
    @State private var selectedIcon = "circle.fill"
    @State private var selectedColorHex = "#FF6B6B"
    @State private var dailyGoal = 1
    @State private var hasTimer = false
    @State private var timerIncrement = 10
    @State private var initialTimerMinutes = 3

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                } header: {
                    Text("Habit")
                }

                Section {
                    // Icon picker
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(Habit.presetIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : .gray)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? Color(hex: selectedColorHex) ?? .blue : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Icon")
                }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(Habit.presetColors, id: \.hex) { color in
                            Button {
                                selectedColorHex = color.hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: color.hex) ?? .gray)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColorHex == color.hex ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Farbe")
                }

                Section {
                    Stepper("Ziel: \(dailyGoal)x pro Tag", value: $dailyGoal, in: 1...10)
                } header: {
                    Text("Tägliches Ziel")
                }

                Section {
                    Toggle("Hat Timer", isOn: $hasTimer)

                    if hasTimer {
                        Stepper("Start: \(initialTimerMinutes) Minuten", value: $initialTimerMinutes, in: 1...60)

                        Stepper("Inkrement: \(timerIncrement)s", value: $timerIncrement, in: 1...60)
                    }
                } header: {
                    Text("Timer")
                } footer: {
                    if hasTimer {
                        Text("Nach jeder Session erhöht sich die Timer-Dauer um \(timerIncrement) Sekunden")
                    }
                }
            }
            .navigationTitle("Neuer Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveHabit()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveHabit() {
        let habit = Habit(
            name: name,
            icon: selectedIcon,
            colorHex: selectedColorHex,
            dailyGoal: dailyGoal,
            hasTimer: hasTimer,
            timerIncrement: timerIncrement,
            currentTimerDuration: initialTimerMinutes * 60,
            sortOrder: habits.count
        )

        modelContext.insert(habit)
        try? modelContext.save()
        dismiss()
    }
}

struct EditHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var habit: Habit
    let habits: [Habit]
    let logs: [HabitLog]

    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $habit.name)
                } header: {
                    Text("Habit")
                }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(Habit.presetIcons, id: \.self) { icon in
                            Button {
                                habit.icon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(habit.icon == icon ? .white : .gray)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(habit.icon == icon ? habit.color : Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Icon")
                }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(Habit.presetColors, id: \.hex) { color in
                            Button {
                                habit.colorHex = color.hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: color.hex) ?? .gray)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: habit.colorHex == color.hex ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Farbe")
                }

                Section {
                    Stepper("Ziel: \(habit.dailyGoal)x pro Tag", value: $habit.dailyGoal, in: 1...10)
                } header: {
                    Text("Tägliches Ziel")
                }

                Section {
                    Toggle("Hat Timer", isOn: $habit.hasTimer)

                    if habit.hasTimer {
                        Stepper(
                            "Aktuelle Dauer: \(habit.currentTimerDuration / 60)min",
                            value: Binding(
                                get: { habit.currentTimerDuration / 60 },
                                set: { habit.currentTimerDuration = $0 * 60 }
                            ),
                            in: 1...120
                        )

                        Stepper("Inkrement: \(habit.timerIncrement)s", value: $habit.timerIncrement, in: 1...60)
                    }
                } header: {
                    Text("Timer")
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Habit löschen")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Habit wirklich löschen?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Löschen", role: .destructive) {
                    deleteHabit()
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Alle Daten für diesen Habit werden gelöscht.")
            }
        }
    }

    private func deleteHabit() {
        // Delete all logs for this habit
        for log in logs where log.habitId == habit.id {
            modelContext.delete(log)
        }
        modelContext.delete(habit)
        try? modelContext.save()
        dismiss()
    }
}

struct HabitSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Daten exportieren") {
                        Text("Export coming soon...")
                    }
                }

                Section {
                    Link("Über diese App", destination: URL(string: "https://github.com")!)
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NewHabitSheet(habits: [])
}
