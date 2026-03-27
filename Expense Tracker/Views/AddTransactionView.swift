import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var vm: ExpenseViewModel
    @Environment(\.dismiss) var dismiss

    @State private var amount: String = ""
    @State private var type: TransactionType = .expense
    @State private var selectedCategory: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""

    private var canSave: Bool {
        amount.isValidPositiveDecimal && !selectedCategory.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Amount") {
                    HStack {
                        Text(vm.settings.currency)
                            .foregroundColor(.secondary)
                            .frame(width: 40)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title3)
                            .onChange(of: amount) { _, new in
                                amount = new.sanitizedAsDecimalInput()
                            }
                    }
                }

                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type) { _, _ in
                        selectedCategory = vm.categories.first?.name ?? ""
                    }
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(vm.categories) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                Text(cat.name)
                            }
                            .tag(cat.name)
                        }
                    }
                }

                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Note (optional)") {
                    TextField("Add a note...", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .onAppear {
                selectedCategory = vm.categories.first?.name ?? ""
            }
        }
    }

    private func save() {
        guard let value = amount.decimalValue, value > 0 else { return }
        vm.addTransaction(Transaction(amount: value, type: type, category: selectedCategory, date: date, note: note))
        dismiss()
    }
}
