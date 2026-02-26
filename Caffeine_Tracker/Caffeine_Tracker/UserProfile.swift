import Foundation

enum WeightUnit: String, Codable, CaseIterable, Hashable, Identifiable {
    case kg
    case lb

    var id: String { rawValue }
}

enum HeightUnit: String, Codable, CaseIterable, Hashable, Identifiable {
    case cm

    var id: String { rawValue }
}

enum SensitivityLevel: String, Codable, CaseIterable, Hashable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

struct UserProfile: Codable, Hashable {
    var weightValue: Double?
    var weightUnit: WeightUnit
    var heightValue: Double?
    var heightUnit: HeightUnit
    var bedtime: Date
    var sensitivityLevel: SensitivityLevel
    var useWeightBasedHints: Bool

    static func `default`() -> UserProfile {
        UserProfile(
            weightValue: nil,
            weightUnit: .kg,
            heightValue: nil,
            heightUnit: .cm,
            bedtime: defaultBedtime(),
            sensitivityLevel: .medium,
            useWeightBasedHints: true
        )
    }

    private static func defaultBedtime(calendar: Calendar = .current) -> Date {
        let now = Date()
        return calendar.date(
            bySettingHour: 23,
            minute: 30,
            second: 0,
            of: now
        ) ?? now
    }
}
