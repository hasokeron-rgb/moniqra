import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: ExpenseViewModel
    @State private var showAddTransaction = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    balanceCard
                    statsRow
                    recentTransactions
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView()
            }
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(vm.formattedAmount(vm.balance))
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(vm.balance >= 0 ? .primary : .red)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            StatCard(title: "Income", amount: vm.currentMonthIncome, color: .green, icon: "arrow.down.circle.fill")
            StatCard(title: "Expenses", amount: vm.currentMonthExpenses, color: .red, icon: "arrow.up.circle.fill")
        }
    }

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
                if vm.transactions.count > 5 {
                    Text("See all")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }

            if vm.transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No transactions yet.\nTap + to add one.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                let recent = Array(vm.transactions.prefix(5))
                ForEach(recent) { transaction in
                    TransactionRowView(transaction: transaction)
                    if transaction.id != recent.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

struct StatCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    @EnvironmentObject var vm: ExpenseViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(vm.formattedAmount(amount))
                .font(.title3)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("This month")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.08))
        )
    }
}
