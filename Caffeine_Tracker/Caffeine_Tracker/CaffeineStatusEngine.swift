import Foundation

enum CaffeineStatusWarningLevel: String, Codable, Hashable {
    case none
    case mild
    case moderate
    case high
}

enum CaffeineState: String, Codable, Hashable {
    case noRecentIntake
    case absorbing
    case rising
    case peakWindow
    case declining
    case lowResidual

    var badgeTitle: String {
        switch self {
        case .noRecentIntake:
            return "No Recent Intake"
        case .absorbing:
            return "Absorbing"
        case .rising:
            return "Rising"
        case .peakWindow:
            return "Peak Window"
        case .declining:
            return "Declining"
        case .lowResidual:
            return "Low Residual"
        }
    }
}

struct CaffeineStatusSnapshot: Hashable {
    let currentState: CaffeineState
    let headlineText: String
    let supportingText: String
    let warningLevel: CaffeineStatusWarningLevel
}

enum CaffeineStatusEngine {
    static func evaluate(
        intakeRecords: [IntakeRecord],
        now: Date,
        currentResidualMg: Double,
        latestIntakeTime: Date?,
        userProfile: UserProfile?
    ) -> CaffeineStatusSnapshot {
        if intakeRecords.isEmpty {
            return CaffeineStatusSnapshot(
                currentState: .noRecentIntake,
                headlineText: "Estimated state: No recent intake",
                supportingText: "Reference estimate based on your logged intakes.",
                warningLevel: .none
            )
        }

        if currentResidualMg < 15 {
            return CaffeineStatusSnapshot(
                currentState: .lowResidual,
                headlineText: "Estimated state: Low residual",
                supportingText: "Reference estimate suggests low remaining caffeine.",
                warningLevel: warningLevel(for: .lowResidual, userProfile: userProfile)
            )
        }

        guard let latestIntakeTime else {
            return CaffeineStatusSnapshot(
                currentState: .declining,
                headlineText: "Estimated state: Declining",
                supportingText: "Estimated from residual level and intake history.",
                warningLevel: warningLevel(for: .declining, userProfile: userProfile)
            )
        }

        let elapsedMinutes = now.timeIntervalSince(latestIntakeTime) / 60

        let state: CaffeineState
        if elapsedMinutes < 0 {
            state = .absorbing
        } else if elapsedMinutes <= 15 {
            state = .absorbing
        } else if elapsedMinutes <= 45 {
            state = .rising
        } else if elapsedMinutes <= 120 {
            state = .peakWindow
        } else {
            state = .declining
        }

        return CaffeineStatusSnapshot(
            currentState: state,
            headlineText: "Estimated state: \(state.badgeTitle)",
            supportingText: supportingText(for: state, userProfile: userProfile),
            warningLevel: warningLevel(for: state, userProfile: userProfile)
        )
    }

    private static func supportingText(for state: CaffeineState, userProfile: UserProfile?) -> String {
        let sensitivitySuffix: String
        if let userProfile, userProfile.sensitivityLevel == .high {
            sensitivitySuffix = " May affect sleep more if your sensitivity is high."
        } else {
            sensitivitySuffix = ""
        }

        switch state {
        case .noRecentIntake:
            return "Reference estimate based on your logged intakes."
        case .absorbing:
            return "Estimated from latest intake timing; effects may still be building.\(sensitivitySuffix)"
        case .rising:
            return "Estimated from latest intake timing; caffeine level may still be rising.\(sensitivitySuffix)"
        case .peakWindow:
            return "Estimated from latest intake timing; this may be near the peak window.\(sensitivitySuffix)"
        case .declining:
            return "Estimated from latest intake timing and half-life reference; levels may be declining.\(sensitivitySuffix)"
        case .lowResidual:
            return "Reference estimate suggests low remaining caffeine.\(sensitivitySuffix)"
        }
    }

    private static func warningLevel(for state: CaffeineState, userProfile: UserProfile?) -> CaffeineStatusWarningLevel {
        let isHighSensitivity = userProfile?.sensitivityLevel == .high

        switch state {
        case .noRecentIntake, .lowResidual:
            return .none
        case .absorbing, .rising:
            return isHighSensitivity ? .moderate : .mild
        case .peakWindow:
            return isHighSensitivity ? .high : .moderate
        case .declining:
            return isHighSensitivity ? .mild : .none
        }
    }
}
