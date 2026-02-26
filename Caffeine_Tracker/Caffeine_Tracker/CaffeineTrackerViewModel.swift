import Foundation
import Combine

@MainActor
final class CaffeineTrackerViewModel: ObservableObject {
    enum AddInputMode: String, CaseIterable, Identifiable {
        case quickPresets
        case brandProducts
        case manualInput

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .quickPresets:
                return "Quick Presets"
            case .brandProducts:
                return "Brand Products"
            case .manualInput:
                return "Manual Input"
            }
        }
    }

    @Published var addInputMode: AddInputMode = .quickPresets
    @Published var selectedQuickPresetItemID: DrinkCatalogItem.ID?
    @Published var selectedBrandName: String = ""
    @Published var selectedBrandProductPresetID: BrandProductPreset.ID?
    @Published var inputCaffeineMgText: String = ""
    @Published var selectedIntakeTime: Date = Date()
    @Published var userProfile: UserProfile = .default()
    @Published var profileWeightText: String = ""
    @Published var profileHeightText: String = ""
    @Published private(set) var records: [IntakeRecord] = []

    let halfLifeHours: Double = 5.0
    let catalogItems: [DrinkCatalogItem] = DrinkCatalog.mvpItems
    let brandProductPresetsUS: [BrandProductPreset] = BrandProductSeed.us

    private let userDefaults: UserDefaults
    private let storageKey = "caffeine_tracker_intake_records_v1"
    private let userProfileStorageKey = "caffeine_tracker_user_profile_v1"
    private let calendar = Calendar.current

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
#if DEBUG
        self.userDefaults.removeObject(forKey: storageKey)
#endif
        loadRecords()
        loadUserProfile()
        configureDefaultBrandSelection()
    }

    var canAddIntake: Bool {
        guard let mg = parsedInputMg else { return false }
        return mg > 0
    }

    var todayRecords: [IntakeRecord] {
        records
            .filter { calendar.isDateInToday($0.consumedAt) }
            .sorted { $0.consumedAt > $1.consumedAt }
    }

    var quickPresetItems: [DrinkCatalogItem] {
        catalogItems.filter { $0.category == .quickPresets }
    }

    var selectedQuickPresetItem: DrinkCatalogItem? {
        guard let id = selectedQuickPresetItemID else { return nil }
        return quickPresetItems.first { $0.id == id }
    }

    var availableBrands: [String] {
        var seen = Set<String>()
        var ordered: [String] = []

        for preset in brandProductPresetsUS {
            if seen.insert(preset.brand).inserted {
                ordered.append(preset.brand)
            }
        }

        return ordered
    }

    func products(for brand: String) -> [BrandProductPreset] {
        brandProductPresetsUS.filter { $0.brand == brand }
    }

    var selectedBrandProductPreset: BrandProductPreset? {
        guard let id = selectedBrandProductPresetID else { return nil }
        return brandProductPresetsUS.first { $0.id == id }
    }

    var estimatedResidualCaffeineMg: Double {
        let now = Date()
        return estimatedResidualCaffeineMg(at: now)
    }

    var latestIntakeTime: Date? {
        records.max(by: { $0.consumedAt < $1.consumedAt })?.consumedAt
    }

    var caffeineStatusSnapshot: CaffeineStatusSnapshot {
        CaffeineStatusEngine.evaluate(
            intakeRecords: records,
            now: Date(),
            currentResidualMg: estimatedResidualCaffeineMg,
            latestIntakeTime: latestIntakeTime,
            userProfile: userProfile
        )
    }

    var bedtimeResidualEstimateMg: Double {
        estimatedResidualCaffeineMg(at: nextBedtimeReferenceDate(from: Date()))
    }

    var bedtimeReferenceDate: Date {
        nextBedtimeReferenceDate(from: Date())
    }

    func addIntake() {
        guard let mg = parsedInputMg, mg > 0 else { return }

        let normalizedTime = normalizedToTodayTime(selectedIntakeTime)
        records.append(IntakeRecord(caffeineMg: mg, consumedAt: normalizedTime))
        records.sort { $0.consumedAt > $1.consumedAt }
        saveRecords()

        inputCaffeineMgText = ""
        selectedIntakeTime = Date()
    }

    func deleteRecord(id: UUID) {
        records.removeAll { $0.id == id }
        saveRecords()
    }

    func applyQuickPresetSelection(_ itemID: DrinkCatalogItem.ID?) {
        selectedQuickPresetItemID = itemID
        guard let itemID else { return }
        guard let item = quickPresetItems.first(where: { $0.id == itemID }) else { return }
        fillInput(with: item)
    }

    func selectBrand(_ brand: String) {
        selectedBrandName = brand

        guard let firstProduct = products(for: brand).first else {
            selectedBrandProductPresetID = nil
            return
        }

        selectedBrandProductPresetID = firstProduct.id
        fillInput(with: firstProduct)
    }

    func selectBrandProduct(_ presetID: BrandProductPreset.ID?) {
        selectedBrandProductPresetID = presetID
        guard let presetID else { return }
        guard let preset = brandProductPresetsUS.first(where: { $0.id == presetID }) else { return }
        fillInput(with: preset)
    }

    func applySelectedBrandProductIfAvailable() {
        guard let preset = selectedBrandProductPreset else { return }
        fillInput(with: preset)
    }

    func saveUserProfile() {
        userProfile.weightValue = parsedOptionalPositiveDouble(from: profileWeightText)
        userProfile.heightValue = parsedOptionalPositiveDouble(from: profileHeightText)
        userProfile.bedtime = normalizedToTodayTime(userProfile.bedtime)

        guard let data = try? JSONEncoder().encode(userProfile) else { return }
        userDefaults.set(data, forKey: userProfileStorageKey)
    }

    func setProfileWeightUnit(_ unit: WeightUnit) {
        userProfile.weightUnit = unit
        saveUserProfile()
    }

    func setProfileHeightUnit(_ unit: HeightUnit) {
        userProfile.heightUnit = unit
        saveUserProfile()
    }

    func setProfileBedtime(_ bedtime: Date) {
        userProfile.bedtime = bedtime
        saveUserProfile()
    }

    func setProfileSensitivityLevel(_ level: SensitivityLevel) {
        userProfile.sensitivityLevel = level
        saveUserProfile()
    }

    func setUseWeightBasedHints(_ enabled: Bool) {
        userProfile.useWeightBasedHints = enabled
        saveUserProfile()
    }

    func setProfileWeightText(_ text: String) {
        profileWeightText = text
        saveUserProfile()
    }

    func setProfileHeightText(_ text: String) {
        profileHeightText = text
        saveUserProfile()
    }

    func useManualInputMode() {
        addInputMode = .manualInput
    }

    private var parsedInputMg: Double? {
        Double(inputCaffeineMgText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func estimatedResidual(for record: IntakeRecord, at now: Date) -> Double {
        let elapsedHours = now.timeIntervalSince(record.consumedAt) / 3600

        guard elapsedHours >= 0 else {
            return 0
        }

        let decayFactor = pow(0.5, elapsedHours / halfLifeHours)
        return record.caffeineMg * decayFactor
    }

    private func estimatedResidualCaffeineMg(at date: Date) -> Double {
        records.reduce(0) { partialResult, record in
            partialResult + estimatedResidual(for: record, at: date)
        }
    }

    private func parsedOptionalPositiveDouble(from text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let value = Double(trimmed), value > 0 else { return nil }
        return value
    }

    private func fillInput(with item: DrinkCatalogItem) {
        inputCaffeineMgText = String(Int(item.caffeineMg.rounded()))
    }

    private func fillInput(with preset: BrandProductPreset) {
        inputCaffeineMgText = String(Int(preset.caffeineMg.rounded()))
    }

    private func configureDefaultBrandSelection() {
        guard let firstBrand = availableBrands.first else { return }
        selectedBrandName = firstBrand
        selectedBrandProductPresetID = products(for: firstBrand).first?.id
    }

    private func normalizedToTodayTime(_ date: Date) -> Date {
        let timeParts = calendar.dateComponents([.hour, .minute], from: date)
        let today = Date()

        return calendar.date(
            bySettingHour: timeParts.hour ?? 0,
            minute: timeParts.minute ?? 0,
            second: 0,
            of: today
        ) ?? today
    }

    private func nextBedtimeReferenceDate(from now: Date) -> Date {
        let bedtimeComponents = calendar.dateComponents([.hour, .minute], from: userProfile.bedtime)

        let todayBedtime = calendar.date(
            bySettingHour: bedtimeComponents.hour ?? 23,
            minute: bedtimeComponents.minute ?? 30,
            second: 0,
            of: now
        ) ?? now

        if todayBedtime > now {
            return todayBedtime
        }

        return calendar.date(byAdding: .day, value: 1, to: todayBedtime) ?? todayBedtime
    }

    private func loadRecords() {
        guard let data = userDefaults.data(forKey: storageKey) else {
            records = []
            return
        }

        do {
            records = try JSONDecoder().decode([IntakeRecord].self, from: data)
                .sorted { $0.consumedAt > $1.consumedAt }
        } catch {
            records = []
        }
    }

    private func loadUserProfile() {
        guard let data = userDefaults.data(forKey: userProfileStorageKey) else {
            userProfile = .default()
            syncProfileInputTextFromModel()
            return
        }

        do {
            userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            userProfile = .default()
        }

        userProfile.bedtime = normalizedToTodayTime(userProfile.bedtime)
        syncProfileInputTextFromModel()
    }

    private func syncProfileInputTextFromModel() {
        if let weightValue = userProfile.weightValue {
            profileWeightText = formatProfileNumber(weightValue)
        } else {
            profileWeightText = ""
        }

        if let heightValue = userProfile.heightValue {
            profileHeightText = formatProfileNumber(heightValue)
        } else {
            profileHeightText = ""
        }
    }

    private func formatProfileNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(format: "%.1f", value)
    }

    private func saveRecords() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
