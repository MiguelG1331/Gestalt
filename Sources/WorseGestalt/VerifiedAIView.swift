//
//  VerifiedAIView.swift
//  worsegestalt
//
//  SPDX-License-Identifier: GPL-3.0-or-later
//

import SwiftUI

struct VerifiedAIView: View {
    @ObservedObject var store: GestaltStore
    @State private var confirmSpoof = false
    @State private var confirmSpoofAndRespring = false
    @State private var working = false
    @State private var showRespringConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("Live values read from disk") {
                    Text("ProductType: " + (store.cacheExtra["h9jDsbgj7xIVeIQ8S3/X3Q"] as? String ?? "absent"))
                    Text("Generative capability: " + String(describing: store.cacheExtra["A62OafQ85EJAiiqKn4agtg"] ?? "absent"))
                    Text(store.verifiedStatus)
                    Text(String(describing: store.state)).font(.caption)
                    Button("Read again") {
                        Task {
                            working = true
                            await store.load()
                            working = false
                        }
                    }
                }

                Section("Experimental AI configuration") {
                    Text("These controls verify cache edits, not working Apple Intelligence. A backup is saved before changes. Export VerifiedOriginal.plist using Files before restarting. Keep a full device backup.")

                    Button {
                        Task {
                            working = true
                            await store.applyVerifiedAI(spoof: false)
                            working = false
                            if store.verifiedStatus.contains("Verified") {
                                showRespringConfirm = true
                            }
                        }
                    } label: {
                        Label("Enable capability only", systemImage: "sparkles")
                    }
                    .disabled(store.state != .loaded)

                    Button {
                        Task {
                            working = true
                            await store.applyVerifiedAI(spoof: false)
                            working = false
                            if store.verifiedStatus.contains("Verified") {
                                performRespring()
                            }
                        }
                    } label: {
                        Label("Enable capability & Respring", systemImage: "bolt.fill")
                    }
                    .disabled(store.state != .loaded)

                    Button {
                        confirmSpoof = true
                    } label: {
                        Label("Enable capability + iPhone 15 Pro identity", systemImage: "iphone")
                    }
                    .disabled(store.state != .loaded)

                    Button {
                        confirmSpoofAndRespring = true
                    } label: {
                        Label("Enable capability + 15 Pro & Respring", systemImage: "arrow.triangle.2.circlepath.circle.fill")
                    }
                    .disabled(store.state != .loaded)

                    Text("Does not change hardware, CPU or region. Does not modify eligibility databases or delete model assets.").font(.footnote)
                }

                Section("Respring / Apply") {
                    Button {
                        performRespring()
                    } label: {
                        Label("Respring now", systemImage: "arrow.clockwise.circle.fill")
                    }
                    Text("Restarts SpringBoard / userspace to apply changes without rebooting the device.").font(.footnote)
                }

                Section("Recovery") {
                    ShareLink("Export original backup", item: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("VerifiedOriginal.plist"))
                    Button("Restore this app's original", role: .destructive) {
                        Task {
                            working = true
                            await store.restoreVerifiedOriginal()
                            working = false
                            if store.verifiedStatus.contains("Restored") || !store.isDirty {
                                showRespringConfirm = true
                            }
                        }
                    }
                    Text("Original means the state before this app's first change. Restore earlier tools' changes before first use.").font(.footnote)
                }

                Section("Log") {
                    NavigationLink("Show log") { LogView() }
                }
            }
            .disabled(working)
            .navigationTitle("Verified Gestalt")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        performRespring()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                working = true
                await store.load()
                working = false
            }
            .onAppear {
                RespringAsset.materialize()
                SandboxEscape.pumpEngineLog()
            }
            .confirmationDialog("Spoofing may break Face ID or other features and require a restore. AI activation is unverified.", isPresented: $confirmSpoof, titleVisibility: .visible) {
                Button("Apply and verify") {
                    Task {
                        working = true
                        await store.applyVerifiedAI(spoof: true)
                        working = false
                        if store.verifiedStatus.contains("Verified") {
                            showRespringConfirm = true
                        }
                    }
                }
            }
            .confirmationDialog("Spoofing may break Face ID or other features and require a restore. Apply and respring immediately?", isPresented: $confirmSpoofAndRespring, titleVisibility: .visible) {
                Button("Apply, verify, and respring") {
                    Task {
                        working = true
                        await store.applyVerifiedAI(spoof: true)
                        working = false
                        if store.verifiedStatus.contains("Verified") {
                            performRespring()
                        }
                    }
                }
            }
            .alert("Changes Applied", isPresented: $showRespringConfirm) {
                Button("Respring Now") {
                    performRespring()
                }
                Button("Later", role: .cancel) {}
            } message: {
                Text("The MobileGestalt cache has been verified on disk. Respring now to restart SpringBoard and make changes active?")
            }
        }
    }

    private func performRespring() {
        RespringAsset.materialize()
        if !NeoSpring.trigger() {
            BQ.respring()
        }
    }
}
