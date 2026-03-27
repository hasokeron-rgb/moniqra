import Foundation
import UserNotifications

class ExpenseViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = Category.defaults
    @Published var settings: AppSettings = AppSettings()

    private let transactionsKey = "transactions"
    private let categoriesKey = "categories"
    private let settingsKey = "settings"

    private let dateFormatter = DateFormatter()

    private static let currencySymbols: [String: String] = [
        "USD": "$", "EUR": "€", "GBP": "£", "UAH": "₴",
        "PLN": "zł", "JPY": "¥", "CAD": "C$", "AUD": "A$"
    ]

    init() {
        loadData()
    }

    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        totalIncome - totalExpenses
    }

    var currentMonthExpenses: Double {
        sumOfTransactions(type: .expense, inSameMonthAs: Date())
    }

    var currentMonthIncome: Double {
        sumOfTransactions(type: .income, inSameMonthAs: Date())
    }

    var budgetRemaining: Double {
        settings.monthlyBudget - currentMonthExpenses
    }

    var budgetProgress: Double {
        guard settings.monthlyBudget > 0 else { return 0 }
        return min(currentMonthExpenses / settings.monthlyBudget, 1.0)
    }

    func expensesByCategory() -> [(category: String, amount: Double)] {
        let monthExpenses = transactions.filter {
            $0.type == .expense && Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month)
        }
        var dict: [String: Double] = [:]
        for t in monthExpenses { dict[t.category, default: 0] += t.amount }
        return dict.map { (category: $0.key, amount: $0.value) }.sorted { $0.amount > $1.amount }
    }

    func expensesByDay(for month: Date = Date()) -> [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let monthExpenses = transactions.filter {
            $0.type == .expense && calendar.isDate($0.date, equalTo: month, toGranularity: .month)
        }
        var dict: [Date: Double] = [:]
        for t in monthExpenses {
            let day = calendar.startOfDay(for: t.date)
            dict[day, default: 0] += t.amount
        }
        return dict.map { (date: $0.key, amount: $0.value) }.sorted { $0.date < $1.date }
    }

    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
        saveData()
        checkBudgetNotification()
    }

    func deleteTransaction(at offsets: IndexSet, from filtered: [Transaction]) {
        let idsToDelete = Set(offsets.map { filtered[$0].id })
        transactions.removeAll { idsToDelete.contains($0.id) }
        saveData()
    }

    func addCategory(_ category: Category) {
        categories.append(category)
        saveData()
    }

    func deleteCategory(at offsets: IndexSet) {
        let custom = categories.filter { !$0.isDefault }
        let idsToDelete = Set(offsets.map { custom[$0].id })
        categories.removeAll { idsToDelete.contains($0.id) }
        saveData()
    }

    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        saveData()
        scheduleReminders()
    }

    func formattedAmount(_ amount: Double) -> String {
        let symbol = Self.currencySymbols[settings.currency] ?? settings.currency + " "
        return String(format: "\(symbol)%.2f", amount)
    }

    func formattedDate(_ date: Date) -> String {
        dateFormatter.dateFormat = settings.dateFormat
        return dateFormatter.string(from: date)
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func sumOfTransactions(type: TransactionType, inSameMonthAs reference: Date) -> Double {
        transactions
            .filter { $0.type == type && Calendar.current.isDate($0.date, equalTo: reference, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    private func saveData() {
        persist(transactions, forKey: transactionsKey)
        persist(categories, forKey: categoriesKey)
        persist(settings, forKey: settingsKey)
    }

    private func loadData() {
        transactions = load([Transaction].self, forKey: transactionsKey) ?? []
        categories = load([Category].self, forKey: categoriesKey) ?? Category.defaults
        settings = load(AppSettings.self, forKey: settingsKey) ?? AppSettings()
    }

    private func persist<T: Encodable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func scheduleReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard settings.remindersEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Expense Tracker"
        content.body = "Don't forget to log your expenses today!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: settings.reminderHour, minute: settings.reminderMinute),
            repeats: true
        )
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        )
    }

    private func checkBudgetNotification() {
        guard settings.remindersEnabled, settings.monthlyBudget > 0,
              currentMonthExpenses > settings.monthlyBudget else { return }

        let content = UNMutableNotificationContent()
        content.title = "Budget Exceeded!"
        content.body = "You've exceeded your monthly budget of \(formattedAmount(settings.monthlyBudget))"
        content.sound = .default

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: "budget_exceeded_\(UUID().uuidString)",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            )
        )
    }
}
