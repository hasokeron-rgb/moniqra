import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: ExpenseViewModel
    @AppStorage("colorScheme") private var colorSchemeRaw: String = "system"

    @State private var localSettings: AppSettings = AppSettings()
    @State private var showAddCategory = false
    @State private var newCategoryName: String = ""

    private let currencies = ["USD", "EUR", "GBP", "UAH", "PLN", "JPY", "CAD", "AUD"]
    private let dateFormats = ["dd/MM/yyyy", "MM/dd/yyyy", "yyyy-MM-dd"]

    var body: some View {
        NavigationView {
            Form {
                Section("Display") {
                    Picker("Currency", selection: $localSettings.currency) {
                        ForEach(currencies, id: \.self) { Text($0).tag($0) }
                    }

                    Picker("Date Format", selection: $localSettings.dateFormat) {
                        ForEach(dateFormats, id: \.self) { Text($0).tag($0) }
                    }

                    Picker("Theme", selection: $colorSchemeRaw) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }

                Section("Reminders") {
                    Toggle("Daily Reminder", isOn: $localSettings.remindersEnabled)
                        .onChange(of: localSettings.remindersEnabled) { _, enabled in
                            if enabled { vm.requestNotificationPermission() }
                        }

                    if localSettings.remindersEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: reminderTimeBinding,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                Section {
                    let custom = vm.categories.filter { !$0.isDefault }
                    if custom.isEmpty {
                        Text("No custom categories")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(custom) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                    .foregroundColor(.accentColor)
                                Text(cat.name)
                            }
                        }
                        .onDelete(perform: vm.deleteCategory)
                    }
                    Button {
                        showAddCategory = true
                    } label: {
                        Label("Add Category", systemImage: "plus")
                    }
                } header: {
                    Text("Custom Categories")
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear { localSettings = vm.settings }
            .onChange(of: localSettings) { _, newValue in
                vm.updateSettings(newValue)
            }
            .sheet(isPresented: $showAddCategory) {
                addCategorySheet
            }
        }
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    from: DateComponents(hour: localSettings.reminderHour, minute: localSettings.reminderMinute)
                ) ?? Date()
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                localSettings.reminderHour = comps.hour ?? 20
                localSettings.reminderMinute = comps.minute ?? 0
            }
        )
    }

    private var addCategorySheet: some View {
        NavigationView {
            Form {
                Section("Category Name") {
                    TextField("e.g. Gym, Travel...", text: $newCategoryName)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newCategoryName = ""
                        showAddCategory = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        vm.addCategory(Category(name: trimmed, icon: "tag.fill", isDefault: false))
                        newCategoryName = ""
                        showAddCategory = false
                    }
                    .fontWeight(.semibold)
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
