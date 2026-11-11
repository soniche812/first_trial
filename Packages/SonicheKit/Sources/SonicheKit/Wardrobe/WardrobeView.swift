import PhotosUI
import SwiftUI
import UIKit

/// The wardrobe tab: items grouped by category, with a button to add new ones.
public struct WardrobeView: View {
    let store: WardrobeStore

    @State private var showingLibrary = false
    @State private var libraryItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var pendingPhoto: PendingPhoto?
    @State private var errorMessage: String?

    public init(store: WardrobeStore) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Group {
                if store.items.isEmpty {
                    emptyState
                } else {
                    itemGrid
                }
            }
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .primaryAction) { addMenu }
            }
            .navigationDestination(for: ClothingItem.self) { item in
                ItemDetailView(item: item, store: store)
            }
        }
        .photosPicker(isPresented: $showingLibrary, selection: $libraryItem, matching: .images)
        .onChange(of: libraryItem) { _, newItem in
            guard let newItem else { return }
            Task { @MainActor in
                await loadLibraryPhoto(newItem)
                libraryItem = nil
            }
        }
        .fullScreenCover(isPresented: $showingCamera, onDismiss: {
            if let capturedImage {
                pendingPhoto = PendingPhoto(image: capturedImage)
                self.capturedImage = nil
            }
        }) {
            CameraPicker { image in capturedImage = image }
                .ignoresSafeArea()
        }
        .sheet(item: $pendingPhoto) { photo in
            AddItemView(image: photo.image) { name, category in
                try saveItem(image: photo.image, name: name, category: category)
            }
        }
        .alert("Something went wrong", isPresented: isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .task {
            if let issue = store.loadIssue {
                errorMessage = issue
                store.acknowledgeLoadIssue()
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Your wardrobe is empty", systemImage: "tshirt")
        } description: {
            Text("Add photos of your clothes so SONICHE can style outfits from them.")
        } actions: {
            addMenu
                .buttonStyle(.borderedProminent)
        }
    }

    /// One grid with a section per category. A single lazy grid keeps scrolling
    /// reliable; nesting lazy grids inside a lazy stack can break the scroll height.
    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], alignment: .leading, spacing: 12) {
                ForEach(ClothingCategory.allCases) { category in
                    let items = store.items(in: category)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { item in
                                NavigationLink(value: item) {
                                    ItemCell(item: item, imageURL: store.imageURL(for: item))
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            Label(category.displayName, systemImage: category.symbolName)
                                .font(.title3.weight(.semibold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 12)
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityIdentifier("category-header-\(category.rawValue)")
                        }
                    }
                }
            }
            .padding()
        }
        .accessibilityIdentifier("wardrobe-grid")
    }

    private var addMenu: some View {
        Menu {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button {
                    showingCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
            }
            Button {
                showingLibrary = true
            } label: {
                Label("Choose from Library", systemImage: "photo.on.rectangle")
            }
        } label: {
            Label("Add Item", systemImage: "plus")
        }
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func loadLibraryPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                errorMessage = "That photo could not be loaded."
                return
            }
            pendingPhoto = PendingPhoto(image: image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func saveItem(image: UIImage, name: String, category: ClothingCategory) throws {
        guard let data = ImageProcessing.jpegData(from: image) else {
            throw WardrobeError.imageEncodingFailed
        }
        try store.add(imageData: data, name: name, category: category)
    }
}

/// A photo waiting to be saved as a new item.
private struct PendingPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
}

/// One square tile in the wardrobe grid.
private struct ItemCell: View {
    let item: ClothingItem
    let imageURL: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay { ItemImage(url: imageURL, contentMode: .fill) }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
            Text(item.displayName)
                .font(.caption)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Empty") {
    WardrobeView(store: .temporary())
}

#Preview("Sample items") {
    WardrobeView(store: .sample())
}
