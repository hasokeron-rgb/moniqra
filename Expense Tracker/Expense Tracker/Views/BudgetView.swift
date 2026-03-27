import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var vm: ExpenseViewModel
    @State private var budgetInput: String = ""
    @State private var isEditing: Bool = false
    @State private var inputError: Bool = false

    private var progressColor: Color {
        if vm.budgetProgress < 0.7 { return .green }
        if vm.budgetProgress < 0.9 { return .orange }
        return .red
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    budgetSetupCard

                    if vm.settings.monthlyBudget > 0 {
                        progressCard
                        breakdownCard
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Budget")
            .onAppear {
                budgetInput = vm.settings.monthlyBudget > 0
                    ? String(format: "%.2f", vm.settings.monthlyBudget)
                    : ""
            }
        }
    }

    private var budgetSetupCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Monthly Budget", systemImage: "calendar.badge.clock")
                .font(.headline)

            if isEditing {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(vm.settings.currency)
                            .foregroundColor(.secondary)
                        TextField("Enter budget", text: $budgetInput)
                            .keyboardType(.decimalPad)
                            .font(.title3)
                            .onChange(of: budgetInput) { _, new in
                                budgetInput = new.sanitizedAsDecimalInput()
                                if inputError { inputError = false }
                            }
                        Button("Save", action: saveBudget)
                            .buttonStyle(.borderedProminent)
                            .disabled(!budgetInput.isValidPositiveDecimal)
                    }

                    if inputError {
                        Text("Enter a valid amount greater than 0")
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: inputError)
            } else {
                HStack {
                    Text(vm.settings.monthlyBudget > 0
                        ? vm.formattedAmount(vm.settings.monthlyBudget)
                        : "Not set")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(vm.settings.monthlyBudget > 0 ? .primary : .secondary)
                    Spacer()
                    Button(vm.settings.monthlyBudget > 0 ? "Edit" : "Set Budget") {
                        isEditing = true
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("This Month's Progress", systemImage: "chart.bar.fill")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Spent")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(vm.formattedAmount(vm.currentMonthExpenses))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 18)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(progressColor.gradient)
                            .frame(
                                width: max(geo.size.width * vm.budgetProgress, vm.budgetProgress > 0 ? 18 : 0),
                                height: 18
                            )
                            .animation(.easeInOut(duration: 0.6), value: vm.budgetProgress)
                    }
                }
                .frame(height: 18)

                HStack {
                    Text(String(format: "%.0f%% used", vm.budgetProgress * 100))
                        .font(.caption)
                        .foregroundColor(progressColor)
                    Spacer()
                    Text("of \(vm.formattedAmount(vm.settings.monthlyBudget))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if vm.budgetRemaining < 0 {
                    Label(
                        "Budget exceeded by \(vm.formattedAmount(abs(vm.budgetRemaining)))",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    private var breakdownCard: some View {
        VStack(spacing: 0) {
            BudgetRow(title: "Monthly Budget", value: vm.formattedAmount(vm.settings.monthlyBudget), color: .blue)
            Divider().padding(.horizontal)
            BudgetRow(title: "Spent This Month", value: vm.formattedAmount(vm.currentMonthExpenses), color: .red)
            Divider().padding(.horizontal)
            BudgetRow(
                title: "Remaining",
                value: vm.formattedAmount(abs(vm.budgetRemaining)),
                color: vm.budgetRemaining >= 0 ? .green : .red,
                prefix: vm.budgetRemaining < 0 ? "-" : ""
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }

    private func saveBudget() {
        guard let value = budgetInput.decimalValue, value > 0 else {
            inputError = true
            return
        }
        var updated = vm.settings
        updated.monthlyBudget = value
        vm.updateSettings(updated)
        isEditing = false
        inputError = false
    }
}

struct BudgetRow: View {
    let title: String
    let value: String
    let color: Color
    var prefix: String = ""

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(prefix + value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
    }
}
