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
    @State private var stretchEnabled = false
    @State private var stretchDuration = 30
    @State private var stretchIncrement = 5
    @State private var stretchProgressive = false
    @State private var stretchExerciseCount = 1
    @State private var stretchFrequencyMultiplier = 1.25

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

        StretchSettingsSection(
            enabled: $stretchEnabled,
            duration: $stretchDuration,
            progressive: $stretchProgressive,
            increment: $stretchIncrement,
            exerciseCount: $stretchExerciseCount,
            frequencyMultiplier: $stretchFrequencyMultiplier
        )
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
            stretchEnabled: stretchEnabled,
            stretchDuration: stretchDuration,
            stretchIncrement: stretchIncrement,
            stretchProgressive: stretchProgressive,
            stretchExerciseCount: stretchExerciseCount,
            stretchFrequencyMultiplier: stretchFrequencyMultiplier,
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

                StretchSettingsSection(
                    enabled: Binding(
                        get: { habit.stretchEnabled },
                        set: { habit.stretchEnabled = $0 }
                    ),
                    duration: $habit.stretchDuration,
                    progressive: $habit.stretchProgressive,
                    increment: $habit.stretchIncrement,
                    exerciseCount: $habit.stretchExerciseCount,
                    frequencyMultiplier: $habit.stretchFrequencyMultiplier
                )

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
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsArray: [AppSettings]

    private var settings: AppSettings? {
        settingsArray.first
    }

    var body: some View {
        NavigationStack {
            List {
                if let settings = settings {
                    StretchCatalogSettingsSection(settings: settings)
                    SignalSettingsSection(settings: settings)
                }

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
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            AppSettings.ensure(in: modelContext)
        }
    }
}

#Preview {
    NewHabitSheet(habits: [])
}

private struct StretchCatalogSettingsSection: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Section {
            Picker("Dehnkatalog", selection: $settings.stretchCatalog) {
                ForEach(StretchCatalogKind.allCases, id: \.self) { catalog in
                    Text(catalog.displayName).tag(catalog)
                }
            }

            Text(settings.stretchCatalog.detailText)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        } header: {
            Text("Dehnkatalog")
        }
    }
}

private struct SignalSettingsSection: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Section {
            Picker("", selection: $settings.signal) {
                ForEach(SignalType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)

            Toggle("Halbzeit-Signal", isOn: $settings.halfwaySignalEnabled)
        } header: {
            Text("Signalart")
        } footer: {
            Text("Bei aktiviertem Halbzeit-Signal ertönt zur Hälfte der Zeit ein Signal")
        }
    }
}

private struct StretchSettingsSection: View {
    @Binding var enabled: Bool
    @Binding var duration: Int
    @Binding var progressive: Bool
    @Binding var increment: Int
    @Binding var exerciseCount: Int
    @Binding var frequencyMultiplier: Double

    var body: some View {
        Section {
            Toggle("Dehnungsübungen vorschlagen", isOn: $enabled)

            if enabled {
                Stepper("Dauer: \(duration)s", value: $duration, in: 10...600, step: 5)

                Toggle("Zeit erhöhen", isOn: $progressive)

                if progressive {
                    Stepper("Inkrement: \(increment)s", value: $increment, in: 1...60)
                }

                Stepper("Übungen pro Session: \(exerciseCount)", value: $exerciseCount, in: 1...6)

                Stepper(
                    "Häufigkeits-Multiplikator: \(frequencyMultiplier, specifier: "%.2f")x",
                    value: $frequencyMultiplier,
                    in: 1.0...1.6,
                    step: 0.05
                )
            }
        } header: {
            Text("Dehnungsübungen")
        } footer: {
            if enabled {
                Text(progressive ? "Nach jeder Übung erhöht sich die Dauer um \(increment) Sekunden" : "Timer bleibt konstant.")
            }
        }
    }
}
