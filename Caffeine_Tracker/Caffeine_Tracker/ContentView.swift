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

    private var todayListViewportHeight: CGFloat {
        let count = viewModel.todayRecords.count
        let visibleRows = min(max(count, 3), 4)
        return CGFloat(visibleRows) * 40
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Caffeine Tracker")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text("Current estimate residual caffeine (mg)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(viewModel.estimatedResidualCaffeineMg, specifier: "%.1f") mg")
                    .font(.title3.weight(.semibold))
            }

            Text("Half-life estimate: 5 hours")
                .font(.subheadline)
                .foregroundStyle(.secondary)

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
        .frame(width: 430)
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
        VStack(alignment: .leading, spacing: 6) {
            Picker(title, selection: selectedID) {
                Text("Select \(title)")
                    .tag(nil as String?)

                ForEach(items) { item in
                    Text("\(item.displayTitle) (\(Int(item.caffeineMg)) mg)")
                        .tag(item.id as String?)
                }
            }
            .pickerStyle(.menu)

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

        return VStack(alignment: .leading, spacing: 6) {
            Picker(
                "Brand",
                selection: Binding(
                    get: { viewModel.selectedBrandName },
                    set: { viewModel.selectBrand($0) }
                )
            ) {
                ForEach(viewModel.availableBrands, id: \.self) { brand in
                    Text(brand).tag(brand)
                }
            }
            .pickerStyle(.menu)

            Picker(
                "Product",
                selection: Binding(
                    get: { viewModel.selectedBrandProductPresetID },
                    set: { viewModel.selectBrandProduct($0) }
                )
            ) {
                ForEach(brandProducts) { preset in
                    Text("\(preset.displayName) (\(Int(preset.caffeineMg)) mg)")
                        .tag(preset.id as String?)
                }
            }
            .pickerStyle(.menu)

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
}

#Preview {
    ContentView()
}
