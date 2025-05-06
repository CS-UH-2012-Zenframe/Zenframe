import SwiftUI

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let content: String
}

struct JournalPage: View {
    @State private var journalEntries: [JournalEntry] = []
    @State private var showingEntrySheet = false
    @State private var selectedEntry: JournalEntry?
    @State private var showingEditSheet = false

    let journalKey = "journal_entries"

    var body: some View {
        ZStack {
            VStack {
                if journalEntries.isEmpty {
                    Spacer()
                    Text("No journal entries yet.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Spacer()
                } else {
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(journalEntries.sorted(by: { $0.date > $1.date })) { entry in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text(entry.content)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(4)

                                    HStack {
                                        Spacer()

                                        // ✏️ Edit Button
                                        Button(action: {
                                            selectedEntry = entry
                                            showingEditSheet = true
                                        }) {
                                            Label("Edit", systemImage: "pencil")
                                                .labelStyle(IconOnlyLabelStyle())
                                                .padding(8)
                                                .background(Color.blue.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                        // 🗑️ Delete Button
                                        Button(action: {
                                            deleteEntry(entry)
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                                .labelStyle(IconOnlyLabelStyle())
                                                .padding(8)
                                                .background(Color.red.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(.systemGray6))
                                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                                )
                                .onTapGesture {
                                    // Optional: Tap anywhere to edit
                                    selectedEntry = entry
                                    showingEditSheet = true
                                }
                                .hoverEffect(.highlight) // iOS hover visual
                            }
                        }
                        .padding()
                    }


                }
            }

            // Floating '+' button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingEntrySheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingEntrySheet) {
            NewJournalEntryView(onSave: addEntry)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let entryToEdit = selectedEntry {
                EditJournalEntryView(entry: entryToEdit, onSave: updateEntry)
            }
        }
        .onAppear(perform: loadEntries)
    }

    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(encoded, forKey: journalKey)
        }
    }

    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: journalKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            journalEntries = decoded
        }
    }

    func addEntry(_ content: String) {
        let newEntry = JournalEntry(id: UUID(), date: Date(), content: content)
        journalEntries.append(newEntry)
        saveEntries()
    }

    func updateEntry(_ updatedEntry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            journalEntries[index] = updatedEntry
            saveEntries()
        }
    }

    func deleteEntry(at offsets: IndexSet) {
        journalEntries.remove(atOffsets: offsets)
        saveEntries()
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveEntries()
    }
}