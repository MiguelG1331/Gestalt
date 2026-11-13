import SwiftUI

struct VerifiedAIView: View {
    @StateObject private var store = GestaltStore()
    @State private var confirmSpoof = false
    @State private var working = false
    var body: some View {
        NavigationStack {
            List {
                Section("Live values read from disk") {
                    Text("ProductType: " + (store.cacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] as? String ?? "absent"))
                    Text("Generative capability: " + String(describing: store.cacheExtra["A62OafQ85EJAiiqKn4agtg"] ?? "absent"))
                    Text(store.verifiedStatus)
                    Text(String(describing: store.state)).font(.caption)
                    Button("Read again") { Task { working = true; await store.load(); working = false } }
                }
                Section("Experimental AI configuration") {
                    Text("These controls verify cache edits, not working Apple Intelligence. A backup is saved before changes. Export VerifiedOriginal.plist using Files before restarting. Keep a full device backup.")
                    Button("Enable capability only") {
                        Task { working = true; await store.applyVerifiedAI(spoof: false); working = false }
                    }.disabled(store.state != .loaded)
                    Button("Enable capability + iPhone 15 Pro identity") { confirmSpoof = true }
                        .disabled(store.state != .loaded)
                    Text("Does not change hardware, CPU or region. Does not modify eligibility databases or delete model assets.").font(.footnote)
                }
                Section("Recovery") {
                    ShareLink("Export original backup", item: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("VerifiedOriginal.plist"))
                    Button("Restore this app's original", role: .destructive) {
                        Task { working = true; await store.restoreVerifiedOriginal(); working = false }
                    }
                    Text("Original means the state before this app's first change. Restore earlier tools' changes before first use.").font(.footnote)
                }
                Section("Log") {
                    NavigationLink("Show log") { LogView() }
                }
            }
            .disabled(working)
            .navigationTitle("Verified Gestalt")
            .task { working = true; await store.load(); working = false }
            .confirmationDialog("Spoofing may break Face ID or other features and require a restore. AI activation is unverified.", isPresented: $confirmSpoof, titleVisibility: .visible) {
                Button("Apply and verify") { Task { working = true; await store.applyVerifiedAI(spoof: true); working = false } }
            }
        }
    }
}
