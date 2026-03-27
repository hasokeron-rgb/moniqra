import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var vm: ExpenseViewModel
    @State private var selectedChart: ChartType = .pie

    enum ChartType: String, CaseIterable {
        case pie = "By Category"
        case bar = "By Day"
    }

    let chartColors: [Color] = [.blue, .orange, .purple, .red, .green, .yellow, .pink, .cyan, .mint, .indigo]

    var categoryData: [(category: String, amount: Double)] {
        vm.expensesByCategory()
    }

    var dailyData: [(date: Date, amount: Double)] {
        vm.expensesByDay()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Picker("Chart", selection: $selectedChart) {
                        ForEach(ChartType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if selectedChart == .pie {
                        pieSection
                    } else {
                        barSection
                    }

                    summaryCard
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Statistics")
        }
    }

    private var pieSection: some View {
        VStack(spacing: 20) {
            if categoryData.isEmpty {
                emptyState
            } else {
                Chart(categoryData.indices, id: \.self) { index in
                    let item = categoryData[index]
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.52),
                        angularInset: 2
                    )
                    .foregroundStyle(chartColors[index % chartColors.count])
                    .cornerRadius(5)
                }
                .frame(height: 260)
                .padding(.horizontal)

                legendView
            }
        }
    }

    private var barSection: some View {
        VStack(spacing: 20) {
            if dailyData.isEmpty {
                emptyState
            } else {
                Chart(dailyData, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 260)
                .padding(.horizontal)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.day())
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
        }
    }

    private var legendView: some View {
        VStack(alignment: .leading, spacing: 10) {
            let total = categoryData.reduce(0) { $0 + $1.amount }
            ForEach(categoryData.indices, id: \.self) { index in
                let item = categoryData[index]
                let pct = total > 0 ? item.amount / total * 100 : 0
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(chartColors[index % chartColors.count])
                        .frame(width: 14, height: 14)
                    Text(item.category)
                        .font(.subheadline)
                    Spacer()
                    Text(vm.formattedAmount(item.amount))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(String(format: "%.1f%%", pct))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 46, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal)
    }

    private var summaryCard: some View {
        HStack(spacing: 0) {
            SummaryItem(title: "Income", value: vm.formattedAmount(vm.currentMonthIncome), color: .green)
            Divider().frame(height: 40)
            SummaryItem(title: "Expenses", value: vm.formattedAmount(vm.currentMonthExpenses), color: .red)
            Divider().frame(height: 40)
            SummaryItem(title: "Balance", value: vm.formattedAmount(vm.currentMonthIncome - vm.currentMonthExpenses),
                        color: vm.currentMonthIncome >= vm.currentMonthExpenses ? .green : .red)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: selectedChart == .pie ? "chart.pie" : "chart.bar")
                .font(.system(size: 52))
                .foregroundColor(.secondary)
            Text("No expense data for this month")
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
}

struct SummaryItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
