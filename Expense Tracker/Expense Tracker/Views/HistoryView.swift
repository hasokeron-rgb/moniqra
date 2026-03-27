import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var vm: ExpenseViewModel
    @State private var filterCategory: String = "All"
    @State private var filterPeriod: FilterPeriod = .month

    enum FilterPeriod: String, CaseIterable {
        case all = "All Time"
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
    }

    var filteredTransactions: [Transaction] {
        var result = vm.transactions
        let calendar = Calendar.current
        let now = Date()

        switch filterPeriod {
        case .today:
            result = result.filter { calendar.isDateInToday($0.date) }
        case .week:
            result = result.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
        case .month:
            result = result.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
        case .all:
            break
        }

        if filterCategory != "All" {
            result = result.filter { $0.category == filterCategory }
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(FilterPeriod.allCases, id: \.self) { period in
                            FilterChip(title: period.rawValue, isSelected: filterPeriod == period) {
                                filterPeriod = period
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(title: "All", isSelected: filterCategory == "All") {
                            filterCategory = "All"
                        }
                        ForEach(vm.categories) { cat in
                            FilterChip(title: cat.name, isSelected: filterCategory == cat.name) {
                                filterCategory = cat.name
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }

                Divider()

                if filteredTransactions.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No transactions found")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRowView(transaction: transaction)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete { offsets in
                            vm.deleteTransaction(at: offsets, from: filteredTransactions)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}
