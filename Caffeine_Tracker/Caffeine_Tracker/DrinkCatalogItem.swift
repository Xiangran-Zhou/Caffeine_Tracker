import Foundation

enum DrinkSourceType: String, Codable, CaseIterable, Hashable {
    case medicalReference
    case brandOfficial

    var displayName: String {
        switch self {
        case .medicalReference:
            return "Medical Reference"
        case .brandOfficial:
            return "Brand Official"
        }
    }
}

enum DrinkCategory: String, Codable, CaseIterable, Hashable {
    case quickPresets
    case brandProducts

    var displayName: String {
        switch self {
        case .quickPresets:
            return "Quick Presets"
        case .brandProducts:
            return "Brand Products"
        }
    }
}

struct DrinkCatalogItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let servingDescription: String
    let caffeineMg: Double
    let category: DrinkCategory
    let sourceName: String
    let sourceType: DrinkSourceType

    var displayTitle: String {
        "\(name) (\(servingDescription))"
    }
}

enum DrinkCatalog {
    static let mvpItems: [DrinkCatalogItem] = [
        DrinkCatalogItem(
            id: "quick-brewed-coffee-8oz",
            name: "Brewed Coffee",
            servingDescription: "8 oz",
            caffeineMg: 96,
            category: .quickPresets,
            sourceName: "Mayo Clinic",
            sourceType: .medicalReference
        ),
        DrinkCatalogItem(
            id: "quick-espresso-1oz",
            name: "Espresso",
            servingDescription: "1 oz",
            caffeineMg: 63,
            category: .quickPresets,
            sourceName: "Mayo Clinic",
            sourceType: .medicalReference
        ),
        DrinkCatalogItem(
            id: "quick-black-tea-8oz",
            name: "Black Tea",
            servingDescription: "8 oz",
            caffeineMg: 48,
            category: .quickPresets,
            sourceName: "Mayo Clinic",
            sourceType: .medicalReference
        ),
        DrinkCatalogItem(
            id: "quick-green-tea-8oz",
            name: "Green Tea",
            servingDescription: "8 oz",
            caffeineMg: 29,
            category: .quickPresets,
            sourceName: "Mayo Clinic",
            sourceType: .medicalReference
        ),
        DrinkCatalogItem(
            id: "quick-cola-8oz",
            name: "Cola",
            servingDescription: "8 oz",
            caffeineMg: 33,
            category: .quickPresets,
            sourceName: "Mayo Clinic",
            sourceType: .medicalReference
        ),
        DrinkCatalogItem(
            id: "quick-energy-drink-8oz",
            name: "Energy Drink",
            servingDescription: "8 oz",
            caffeineMg: 79,
            category: .quickPresets,
            sourceName: "Mayo Clinic",
            sourceType: .medicalReference
        ),
        DrinkCatalogItem(
            id: "brand-red-bull-8-4oz",
            name: "Red Bull",
            servingDescription: "8.4 oz",
            caffeineMg: 80,
            category: .brandProducts,
            sourceName: "Red Bull",
            sourceType: .brandOfficial
        ),
        DrinkCatalogItem(
            id: "brand-red-bull-12oz",
            name: "Red Bull",
            servingDescription: "12 oz",
            caffeineMg: 114,
            category: .brandProducts,
            sourceName: "Red Bull",
            sourceType: .brandOfficial
        ),
        DrinkCatalogItem(
            id: "brand-red-bull-16oz",
            name: "Red Bull",
            servingDescription: "16 oz",
            caffeineMg: 151,
            category: .brandProducts,
            sourceName: "Red Bull",
            sourceType: .brandOfficial
        ),
        DrinkCatalogItem(
            id: "brand-coca-cola-12oz",
            name: "Coca-Cola",
            servingDescription: "12 oz",
            caffeineMg: 34,
            category: .brandProducts,
            sourceName: "The Coca-Cola Company",
            sourceType: .brandOfficial
        ),
        DrinkCatalogItem(
            id: "brand-diet-coke-12oz",
            name: "Diet Coke",
            servingDescription: "12 oz",
            caffeineMg: 46,
            category: .brandProducts,
            sourceName: "The Coca-Cola Company",
            sourceType: .brandOfficial
        )
    ]
}
