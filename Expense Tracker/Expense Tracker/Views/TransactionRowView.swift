import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    @EnvironmentObject var vm: ExpenseViewModel

    private var categoryIcon: String {
        vm.categories.first { $0.name == transaction.category }?.icon ?? "questionmark.circle"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(transaction.type == .income ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: categoryIcon)
                    .foregroundColor(transaction.type == .income ? .green : .red)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Text(vm.formattedDate(transaction.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(transaction.type == .income ? "+" : "-")\(vm.formattedAmount(transaction.amount))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
