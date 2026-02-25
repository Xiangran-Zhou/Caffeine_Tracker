import Foundation

struct IntakeRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let caffeineMg: Double
    let consumedAt: Date

    init(id: UUID = UUID(), caffeineMg: Double, consumedAt: Date) {
        self.id = id
        self.caffeineMg = caffeineMg
        self.consumedAt = consumedAt
    }
}
