import Foundation

extension String {
    func sanitizedAsDecimalInput() -> String {
        let filtered = filter { $0.isNumber || $0 == "." || $0 == "," }
        let normalized = filtered.replacingOccurrences(of: ",", with: ".")
        let parts = normalized.components(separatedBy: ".")
        guard parts.count > 2 else { return normalized }
        return parts[0] + "." + parts[1]
    }

    var isValidPositiveDecimal: Bool {
        guard let value = Double(replacingOccurrences(of: ",", with: ".")) else { return false }
        return value > 0
    }

    var decimalValue: Double? {
        Double(replacingOccurrences(of: ",", with: "."))
    }
}
