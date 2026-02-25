import Foundation

enum BrandProductCategory: String, Codable, CaseIterable, Hashable {
    case soda
    case energy
}

struct BrandProductPreset: Identifiable, Codable, Hashable {
    let id: String
    let brand: String
    let productName: String
    let sizeOz: Double
    let sizeLabel: String
    let caffeineMg: Double
    let region: String
    let sourceName: String
    let sourceType: DrinkSourceType
    let sourceURL: String
    let lastVerifiedAt: String
    let notes: String?
    let category: BrandProductCategory?

    var displayName: String {
        "\(productName), \(sizeLabel)"
    }
}
