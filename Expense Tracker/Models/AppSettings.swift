import Foundation

struct AppSettings: Codable, Equatable {
    var currency: String = "USD"
    var dateFormat: String = "dd/MM/yyyy"
    var monthlyBudget: Double = 0
    var remindersEnabled: Bool = false
    var reminderHour: Int = 20
    var reminderMinute: Int = 0
}
