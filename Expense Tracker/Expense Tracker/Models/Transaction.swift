import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
}

struct Transaction: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var type: TransactionType
    var category: String
    var date: Date
    var note: String

    init(amount: Double, type: TransactionType, category: String, date: Date = Date(), note: String = "") {
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.note = note
    }
}
