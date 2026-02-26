//
//  ContentView.swift
//  Caffeine_Tracker
//
//  Created by kevin zhou on 2/24/26.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = CaffeineTrackerViewModel()
    @State private var isProfileSectionExpanded = false
    @State private var isQuickPresetListExpanded = false
    @State private var isBrandListExpanded = false
    @State private var isBrandProductListExpanded = false

    private var todayListViewportHeight: CGFloat {
        let count = viewModel.todayRecords.count
        let visibleRows = min(max(count, 3), 4)
        return CGFloat(visibleRows) * 40
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Caffeine Tracker")
                .font(.headline)

            heroStatusSection

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Add Intake")
                    .font(.subheadline.weight(.medium))

                Picker("Add Method", selection: $viewModel.addInputMode) {
                    ForEach(CaffeineTrackerViewModel.AddInputMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                addMethodSelectionSection

                TextField("Caffeine mg", text: $viewModel.inputCaffeineMgText)
                    .textFieldStyle(.roundedBorder)

                DatePicker(
                    "Time",
                    selection: $viewModel.selectedIntakeTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.stepperField)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button("Add") {
                    viewModel.addIntake()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canAddIntake)
            }

            Divider()

            profileSection

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Intakes")
                    .font(.subheadline.weight(.medium))

                if viewModel.todayRecords.isEmpty {
                    Text("No records yet today.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(viewModel.todayRecords) { record in
                                HStack(spacing: 8) {
                                    Text(record.consumedAt, format: .dateTime.hour().minute())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Text("\(record.caffeineMg, specifier: "%.0f") mg")
                                        .font(.caption.weight(.medium))

                                    Button("Delete", role: .destructive) {
                                        viewModel.deleteRecord(id: record.id)
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .help("Delete record")
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .frame(height: todayListViewportHeight)
                }
            }

            Divider()

            HStack {
                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 460)
    }

    @ViewBuilder
    private var addMethodSelectionSection: some View {
        switch viewModel.addInputMode {
        case .quickPresets:
            catalogPickerSection(
                title: "Quick Preset",
                items: viewModel.quickPresetItems,
                selectedID: Binding(
                    get: { viewModel.selectedQuickPresetItemID },
                    set: { viewModel.applyQuickPresetSelection($0) }
                ),
                selectedItem: viewModel.selectedQuickPresetItem
            )
        case .brandProducts:
            brandProductsSelectionSection
        case .manualInput:
            Text("Manual Input mode: enter caffeine mg directly below, then adjust time and tap Add.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func catalogPickerSection(
        title: String,
        items: [DrinkCatalogItem],
        selectedID: Binding<String?>,
        selectedItem: DrinkCatalogItem?
    ) -> some View {
        let quickPresetListHeight = min(max(CGFloat(items.count) * 34, 44), 140)

        return VStack(alignment: .leading, spacing: 6) {
            inlineSelectionField(
                label: title,
                selectedText: selectedItem.map { "\($0.displayTitle) (\(Int($0.caffeineMg)) mg)" } ?? "Select \(title)",
                isExpanded: $isQuickPresetListExpanded
            ) {
                Button("Clear Selection") {
                    selectedID.wrappedValue = nil
                    isQuickPresetListExpanded = false
                }
                .buttonStyle(.plain)

                Divider()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(items) { item in
                            Button {
                                selectedID.wrappedValue = item.id
                                isQuickPresetListExpanded = false
                            } label: {
                                HStack {
                                    Text("\(item.displayTitle) (\(Int(item.caffeineMg)) mg)")
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .frame(height: quickPresetListHeight)
            }

            if let selectedItem {
                Text("Auto-filled from \(selectedItem.sourceName) (\(selectedItem.sourceType.displayName))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Choose a \(title.lowercased()) to auto-fill caffeine mg.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var brandProductsSelectionSection: some View {
        let selectedPreset = viewModel.selectedBrandProductPreset
        let brandProducts = viewModel.products(for: viewModel.selectedBrandName)
        let brandProductListHeight = min(max(CGFloat(brandProducts.count) * 34, 44), 160)

        return VStack(alignment: .leading, spacing: 6) {
            inlineLabeledSelectionField(
                label: "Brand",
                selectedText: viewModel.selectedBrandName.isEmpty ? "Select Brand" : viewModel.selectedBrandName,
                isExpanded: $isBrandListExpanded
            ) {
                ForEach(viewModel.availableBrands, id: \.self) { brand in
                    Button {
                        viewModel.selectBrand(brand)
                        isBrandListExpanded = false
                        isBrandProductListExpanded = false
                    } label: {
                        HStack {
                            Text(brand)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }

            inlineLabeledSelectionField(
                label: "Product",
                selectedText: selectedPreset.map { "\($0.displayName) (\(Int($0.caffeineMg)) mg)" } ?? "Select Product",
                isExpanded: $isBrandProductListExpanded
            ) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(brandProducts) { preset in
                            Button {
                                viewModel.selectBrandProduct(preset.id)
                                isBrandProductListExpanded = false
                            } label: {
                                HStack {
                                    Text("\(preset.displayName) (\(Int(preset.caffeineMg)) mg)")
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .frame(height: brandProductListHeight)
            }

            if let selectedPreset {
                Text("Auto-filled from \(selectedPreset.sourceName) [\(selectedPreset.region)]")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Verified: \(selectedPreset.lastVerifiedAt)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if let notes = selectedPreset.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Select a brand and product to auto-fill caffeine mg.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            viewModel.applySelectedBrandProductIfAvailable()
        }
    }

    private var profileSection: some View {
        DisclosureGroup(
            isExpanded: $isProfileSectionExpanded,
            content: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        TextField(
                            "Weight",
                            text: Binding(
                                get: { viewModel.profileWeightText },
                                set: { viewModel.setProfileWeightText($0) }
                            )
                        )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)

                        Picker(
                            "Weight Unit",
                            selection: Binding(
                                get: { viewModel.userProfile.weightUnit },
                                set: { viewModel.setProfileWeightUnit($0) }
                            )
                        ) {
                            ForEach(WeightUnit.allCases) { unit in
                                Text(unit.rawValue.uppercased()).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    HStack(spacing: 8) {
                        TextField(
                            "Height",
                            text: Binding(
                                get: { viewModel.profileHeightText },
                                set: { viewModel.setProfileHeightText($0) }
                            )
                        )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)

                        Text(viewModel.userProfile.heightUnit.rawValue)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.gray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Text("Height is stored for profile only and is not used in caffeine calculations yet.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    DatePicker(
                        "Bedtime",
                        selection: Binding(
                            get: { viewModel.userProfile.bedtime },
                            set: { viewModel.setProfileBedtime($0) }
                        ),
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.stepperField)

                    Picker(
                        "Sensitivity",
                        selection: Binding(
                            get: { viewModel.userProfile.sensitivityLevel },
                            set: { viewModel.setProfileSensitivityLevel($0) }
                        )
                    ) {
                        ForEach(SensitivityLevel.allCases) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle(
                        "Use weight-based hints",
                        isOn: Binding(
                            get: { viewModel.userProfile.useWeightBasedHints },
                            set: { viewModel.setUseWeightBasedHints($0) }
                        )
                    )

                    HStack {
                        Spacer()

                        Button("Save Profile") {
                            viewModel.saveUserProfile()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.top, 6)
            },
            label: {
                Text("Profile & Preferences")
                    .font(.subheadline.weight(.medium))
            }
        )
    }

    private var heroStatusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current estimated active caffeine")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(viewModel.estimatedResidualCaffeineMg, specifier: "%.1f") mg")
                            .font(.title2.weight(.semibold))
                    }

                    Spacer()

                    statusBadge(
                        title: viewModel.caffeineStatusSnapshot.currentState.badgeTitle,
                        warningLevel: viewModel.caffeineStatusSnapshot.warningLevel
                    )
                }

                Text(viewModel.caffeineStatusSnapshot.headlineText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(viewModel.caffeineStatusSnapshot.supportingText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text("Estimated / half-life based. Reference only.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            quickInsightsRow
            gaugesSection
        }
    }

    private var quickInsightsRow: some View {
        HStack(spacing: 8) {
            insightTile(
                title: "Today Total",
                value: "\(formatted(viewModel.todayTotalCaffeineMg, "%.0f")) mg",
                subtitle: "Logged today"
            )

            insightTile(
                title: "At Bedtime",
                value: "~\(formatted(viewModel.bedtimeResidualEstimateMg, "%.0f")) mg",
                subtitle: viewModel.bedtimeReferenceDate.formatted(.dateTime.hour().minute())
            )

            if let mgPerKg = viewModel.latestIntakeMgPerKg {
                insightTile(
                    title: "Latest mg/kg",
                    value: formatted(mgPerKg, "%.2f"),
                    subtitle: "Estimate"
                )
            } else if let latest = viewModel.latestIntakeRecord {
                insightTile(
                    title: "Last Intake",
                    value: "\(formatted(latest.caffeineMg, "%.0f")) mg",
                    subtitle: latest.consumedAt.formatted(.dateTime.hour().minute())
                )
            } else {
                insightTile(
                    title: "Last Intake",
                    value: "None",
                    subtitle: "No records"
                )
            }
        }
    }

    private var gaugesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            gaugeCard(
                title: "Today Total vs Daily Reference",
                value: viewModel.todayTotalCaffeineMg,
                range: 0...viewModel.dailyReferenceMg,
                valueText: "\(formatted(viewModel.todayTotalCaffeineMg, "%.0f")) mg",
                maxText: "\(formatted(viewModel.dailyReferenceMg, "%.0f")) mg",
                caption: "General adult daily reference shown for context."
            )

            if let latestMgPerKg = viewModel.latestIntakeMgPerKg {
                gaugeCard(
                    title: "Latest Intake mg/kg (Reference Context)",
                    value: latestMgPerKg,
                    range: 0...viewModel.weightBasedSingleDoseReferenceMgPerKg,
                    valueText: "\(formatted(latestMgPerKg, "%.2f")) mg/kg",
                    maxText: "\(formatted(viewModel.weightBasedSingleDoseReferenceMgPerKg, "%.1f")) mg/kg",
                    caption: "Weight-based hint is an estimate and not medical advice."
                )
            } else {
                gaugeCard(
                    title: "Current Residual Visual Scale",
                    value: viewModel.estimatedResidualCaffeineMg,
                    range: 0...viewModel.residualVisualScaleMaxMg,
                    valueText: "\(formatted(viewModel.estimatedResidualCaffeineMg, "%.1f")) mg",
                    maxText: "\(formatted(viewModel.residualVisualScaleMaxMg, "%.0f")) mg",
                    caption: "Visual scale for reference; not a limit or diagnosis."
                )
            }
        }
    }

    private func insightTile(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func gaugeCard(
        title: String,
        value: Double,
        range: ClosedRange<Double>,
        valueText: String,
        maxText: String,
        caption: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            metricGauge(
                value: min(max(value, range.lowerBound), range.upperBound),
                range: range,
                valueText: valueText,
                maxText: maxText
            )

            Text(caption)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func metricGauge(
        value: Double,
        range: ClosedRange<Double>,
        valueText: String,
        maxText: String
    ) -> some View {
        if #available(macOS 13.0, *) {
            Gauge(value: value, in: range) {
                EmptyView()
            } currentValueLabel: {
                Text(valueText)
                    .font(.caption)
            } minimumValueLabel: {
                Text("0")
                    .font(.caption2)
            } maximumValueLabel: {
                Text(maxText)
                    .font(.caption2)
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: value, total: range.upperBound)
                Text("\(valueText) / \(maxText)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func statusBadge(title: String, warningLevel: CaffeineStatusWarningLevel) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusBadgeColor(for: warningLevel).opacity(0.18))
            .foregroundStyle(statusBadgeColor(for: warningLevel))
            .clipShape(Capsule())
    }

    private func statusBadgeColor(for level: CaffeineStatusWarningLevel) -> Color {
        switch level {
        case .none:
            return .secondary
        case .mild:
            return .blue
        case .moderate:
            return .orange
        case .high:
            return .red
        }
    }

    private func formatted(_ value: Double, _ format: String) -> String {
        String(format: format, value)
    }

    private func inlineSelectionField<Content: View>(
        label: String,
        selectedText: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder options: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                isExpanded.wrappedValue.toggle()
            } label: {
                HStack(spacing: 6) {
                    Text(selectedText)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label)

            if isExpanded.wrappedValue {
                VStack(alignment: .leading, spacing: 4) {
                    options()
                }
                .padding(8)
                .background(Color.gray.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func inlineLabeledSelectionField<Content: View>(
        label: String,
        selectedText: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder options: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(label)
                    .frame(width: 58, alignment: .leading)

                Button {
                    isExpanded.wrappedValue.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedText)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            if isExpanded.wrappedValue {
                VStack(alignment: .leading, spacing: 4) {
                    options()
                }
                .padding(8)
                .background(Color.gray.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.leading, 66)
            }
        }
    }

}

#Preview {
    ContentView()
}
