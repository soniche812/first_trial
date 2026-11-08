import SwiftUI

/// Full view of one wardrobe item, with an option to delete it.
struct ItemDetailView: View {
    let item: ClothingItem
    let store: WardrobeStore

    @Environment(\.dismiss) private var dismiss
    @State private var confirmingDelete = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ItemImage(url: store.imageURL(for: item), contentMode: .fit)
                    .frame(maxWidth: .infinity, minHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Label(item.category.singularName, systemImage: item.category.symbolName)
                    .font(.headline)
                Text("Added \(item.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(item.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    confirmingDelete = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .confirmationDialog("Delete this item?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { delete() }
        } message: {
            Text("The photo will be removed from your wardrobe.")
        }
        .alert("Could not delete", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func delete() {
        do {
            try store.delete(item)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
