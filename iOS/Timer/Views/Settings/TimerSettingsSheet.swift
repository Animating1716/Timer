import SwiftUI
import SwiftData

struct TimerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var settings: AppSettings
    @Bindable var timerVM: TimerViewModel

    var body: some View {
        NavigationStack {
            List {
                // Signal Type
                Section {
                    Picker("", selection: $settings.signal) {
                        ForEach(SignalType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Signalart")
                }

                // Statistics
                Section {
                    HStack {
                        Text("Aktuelle Dauer")
                        Spacer()
                        Text(timerVM.timeString)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Gesamtzeit")
                        Spacer()
                        Text(formatTotalTime(settings.totalTimerSeconds))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Statistik")
                }

                // Timer Increment (for selected habit)
                if let habit = timerVM.selectedHabit {
                    Section {
                        Stepper(
                            "Inkrement: \(habit.timerIncrement)s",
                            value: Binding(
                                get: { habit.timerIncrement },
                                set: { habit.timerIncrement = $0 }
                            ),
                            in: 1...60
                        )
                    } header: {
                        Text("Timer-Einstellungen")
                    } footer: {
                        Text("Zeit die nach jeder Session hinzugefügt wird")
                    }
                }

                // Reset
                Section {
                    Button(role: .destructive) {
                        timerVM.resetTimer(settings: settings, modelContext: modelContext)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Alles zurücksetzen")
                            Spacer()
                        }
                    }
                } footer: {
                    Text("Setzt Timer-Dauer und Gesamtzeit zurück.")
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
        .presentationDragIndicator(.visible)
    }

    private func formatTotalTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes)min"
        }
    }
}

#Preview {
    TimerSettingsSheet(
        settings: AppSettings(),
        timerVM: TimerViewModel()
    )
}
