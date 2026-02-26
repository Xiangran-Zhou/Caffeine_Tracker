import Foundation

struct TimelinePoint: Identifiable, Hashable {
    let id: Date
    let time: Date
    let estimatedResidualMg: Double
    let isNowMarker: Bool
    let isBedtimeMarker: Bool

    init(
        time: Date,
        estimatedResidualMg: Double,
        isNowMarker: Bool = false,
        isBedtimeMarker: Bool = false
    ) {
        self.id = time
        self.time = time
        self.estimatedResidualMg = estimatedResidualMg
        self.isNowMarker = isNowMarker
        self.isBedtimeMarker = isBedtimeMarker
    }
}
