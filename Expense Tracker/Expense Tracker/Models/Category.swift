import Foundation

struct Category: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var icon: String
    var isDefault: Bool

    static let defaults: [Category] = [
        Category(name: "Food", icon: "fork.knife", isDefault: true),
        Category(name: "Transport", icon: "car.fill", isDefault: true),
        Category(name: "Entertainment", icon: "gamecontroller.fill", isDefault: true),
        Category(name: "Shopping", icon: "bag.fill", isDefault: true),
        Category(name: "Health", icon: "heart.fill", isDefault: true),
        Category(name: "Bills", icon: "doc.text.fill", isDefault: true),
        Category(name: "Salary", icon: "banknote.fill", isDefault: true),
        Category(name: "Other", icon: "ellipsis.circle.fill", isDefault: true),
    ]
}
