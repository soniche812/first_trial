import SwiftUI
import UIKit

/// Sheet for naming and categorizing a new photo before saving it.
struct AddItemView: View {
    let image: UIImage
    let onSave: (String, ClothingCategory) throws -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category: ClothingCategory = .top
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .listRowBackground(Color.clear)

                Section("Details") {
                    TextField("Name (optional)", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(ClothingCategory.allCases) { category in
                            Label(category.singularName, systemImage: category.symbolName)
                                .tag(category)
                        }
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        do {
            try onSave(name, category)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
