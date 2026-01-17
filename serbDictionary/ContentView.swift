import SwiftUI
import SharedDictionary

// MARK: - Views
struct WordOfTheDayCard: View {
    let entry: DictionaryEntry
    let isEnglishToSerbian: Bool
    let onDismiss: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isEnglishToSerbian ? "Word of the Day" : "Реч Дана")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 20))
                }
                .applyGlassEffect()
            }
            
            if isEnglishToSerbian {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.translation.english.word)
                        .font(.system(size: 24, weight: .bold))
                    Text(entry.translation.english.part_of_speech)
                        .font(.system(size: 14))
                        .foregroundColor(Color.partOfSpeechColors.colorForPartOfSpeech(entry.translation.english.part_of_speech))
                }
                Text(entry.translation.english.definition)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.translation.cyrillic.word)
                        .font(.system(size: 24, weight: .bold))
                    Text(entry.translation.cyrillic.part_of_speech)
                        .font(.system(size: 14))
                        .foregroundColor(Color.partOfSpeechColors.colorForPartOfSpeech(entry.translation.cyrillic.part_of_speech))
                }
                Text(entry.translation.cyrillic.definition)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct WordListItemView: View {
    let entry: DictionaryEntry
    let isEnglishToSerbian: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if isEnglishToSerbian {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.translation.english.word)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(entry.translation.english.part_of_speech)
                    .font(.system(size: 11))
                    .foregroundColor(Color(.systemBackground))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.partOfSpeechColors.colorForPartOfSpeech(entry.translation.english.part_of_speech))
                    )
                    .fixedSize(horizontal: true, vertical: false)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.translation.cyrillic.word)
                        .font(.headline)
                    Text(entry.translation.latin.word)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.translation.cyrillic.word)
                        .font(.headline)
                    Text(entry.translation.latin.word)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(entry.translation.cyrillic.part_of_speech)
                    .font(.system(size: 11))
                    .foregroundColor(Color(.systemBackground))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.partOfSpeechColors.colorForPartOfSpeech(entry.translation.cyrillic.part_of_speech))
                    )
                    .fixedSize(horizontal: true, vertical: false)
                
                Text(entry.translation.english.word)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct UpdateToast: View {
    let count: Int
    let isEnglish: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(isEnglish ? "\(count) new word\(count == 1 ? "" : "s") added!" : "\(count) нов\(count == 1 ? "а реч додата" : "е речи додате")!")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .shadow(color: Color.primary.opacity(0.15), radius: 10, x: 0, y: 5)
        )
    }
}

struct DatabaseErrorView: View {
    let errorMessage: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Database Error")
                .font(.title2)
                .fontWeight(.bold)

            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Try these steps:")
                    .font(.headline)
                Text("• Restart the app")
                Text("• Check available storage")
                Text("• Reinstall if the issue persists")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct WordListView: View {
    let filteredWords: [DictionaryEntry]
    let isEnglishToSerbian: Bool
    let isLoading: Bool
    @Binding var selectedEntry: DictionaryEntry?

    var body: some View {
        Group {
            if isLoading {
                // Show skeleton loaders while loading
                List(0..<8, id: \.self) { _ in
                    WordListItemSkeleton(isEnglishToSerbian: isEnglishToSerbian)
                }
                .listStyle(PlainListStyle())
            } else if filteredWords.isEmpty {
                VStack {
                    Spacer()
                    Text("No results found")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List(filteredWords) { entry in
                    Button(action: {
                        selectedEntry = entry
                    }) {
                        WordListItemView(entry: entry, isEnglishToSerbian: isEnglishToSerbian)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(PlainListStyle())
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                )
            }
        }
        .background(Color(.systemBackground))
    }
}

class NotificationHandler: ObservableObject {
    var onEntrySelected: ((DictionaryEntry) -> Void)?
    
    init() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowWordDetail"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let entry = notification.userInfo?["entry"] as? DictionaryEntry {
                self?.onEntrySelected?(entry)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct ContentView: View {
    @AppStorage("selectedSerbianLetter") private var selectedSerbianLetter: String = "А"
    @AppStorage("selectedEnglishLetter") private var selectedEnglishLetter: String = "A"
    @AppStorage("isEnglishToSerbian") private var isEnglishToSerbian: Bool = false
    @AppStorage("showWordOfDay") private var showWordOfDay: Bool = true
    
    @StateObject private var notificationHandler = NotificationHandler()
    @State private var dictionary: [DictionaryEntry] = []
    @State private var searchText: String = ""
    @State private var selectedEntry: DictionaryEntry? = nil
    @State private var starButtonRotation: Double = 0

    @State private var isLoading = true
    @State private var databaseError: String?
    @State private var updateCount: Int = 0
    @State private var showUpdateToast: Bool = false

    private var currentDictionary: [DictionaryEntry] {
        dictionary.sorted {
            isEnglishToSerbian ?
            $0.translation.english.word.localizedCaseInsensitiveCompare($1.translation.english.word) == .orderedAscending :
            $0.translation.cyrillic.word.localizedCaseInsensitiveCompare($1.translation.cyrillic.word) == .orderedAscending
        }
    }

    private var wordOfTheDay: DictionaryEntry? {
        DictionaryEntry.wordOfTheDay(from: dictionary)
    }
    
    private var selectedLetter: String {
        isEnglishToSerbian ? selectedEnglishLetter : selectedSerbianLetter
    }
    
    private func setSelectedLetter(_ letter: String) {
        if isEnglishToSerbian {
            selectedEnglishLetter = letter
        } else {
            selectedSerbianLetter = letter
        }
    }

    private func filterWords() -> [DictionaryEntry] {
        if searchText.isEmpty {
            return currentDictionary.filter {
                let word = isEnglishToSerbian ?
                    $0.translation.english.word :
                    $0.translation.cyrillic.word
                return word.uppercased().hasPrefix(selectedLetter)
            }
        } else {
            return currentDictionary.filter {
                $0.translation.english.word.localizedCaseInsensitiveContains(searchText) ||
                $0.translation.cyrillic.word.localizedCaseInsensitiveContains(searchText) ||
                $0.translation.latin.word.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func loadDictionary() {
        Task {
            // Check for remote updates first
            let updates = await UpdateManager.shared.checkForUpdates()

            let (entries, error) = await Task.detached { () -> ([DictionaryEntry], String?) in
                let dbManager = DatabaseManager.shared
                if !dbManager.isReady {
                    return ([], dbManager.lastError)
                }
                return (dbManager.loadEntries(), nil)
            }.value

            await MainActor.run {
                dictionary = entries
                databaseError = error
                isLoading = false

                // Show toast if updates were applied
                if updates > 0 {
                    updateCount = updates
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showUpdateToast = true
                    }
                    // Auto-hide after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showUpdateToast = false
                        }
                    }
                }
            }
        }
    }
    
    struct AlphabetBarView: View {
        let isEnglishToSerbian: Bool
        @Binding var selectedLetter: String
        private let haptic = UIImpactFeedbackGenerator(style: .light)
        
        private let serbianAlphabet = [
            "А", "Б", "В", "Г", "Д", "Ђ", "Е", "Ж", "З", "И", "Ј", "К", "Л", "Љ", "М",
            "Н", "Њ", "О", "П", "Р", "С", "Т", "Ћ", "У", "Ф", "Х", "Ц", "Ч", "Џ", "Ш"
        ]
        
        private let englishAlphabet = [
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
            "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
        ]
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(isEnglishToSerbian ? englishAlphabet : serbianAlphabet, id: \.self) { letter in
                        Button(action: {
                            haptic.impactOccurred()
                            selectedLetter = letter
                        }) {
                            Text(letter)
                                .font(.headline)
                                .foregroundColor(selectedLetter == letter ? .blue : .primary)
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Word of the Day Card - Show skeleton while loading
                if showWordOfDay {
                    if isLoading {
                        WordOfTheDayCardSkeleton(isEnglishToSerbian: isEnglishToSerbian)
                            .padding(.horizontal)
                    } else if let wordOfDay = wordOfTheDay {
                        WordOfTheDayCard(
                            entry: wordOfDay,
                            isEnglishToSerbian: isEnglishToSerbian,
                            onDismiss: {
                                withAnimation {
                                    showWordOfDay = false
                                }
                            },
                            onTap: { selectedEntry = wordOfDay }
                        )
                        .padding(.horizontal)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 1.1).combined(with: .opacity)
                        ))
                    }
                }

                if let error = databaseError {
                    DatabaseErrorView(errorMessage: error)
                } else {
                    WordListView(
                        filteredWords: filterWords(),
                        isEnglishToSerbian: isEnglishToSerbian,
                        isLoading: isLoading,
                        selectedEntry: $selectedEntry
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showWordOfDay)
            .navigationTitle(isEnglishToSerbian ? "English" : "Српски")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Претражи | Pretraži | Search")
            .toolbar {
                // TRAILING: Replace both original buttons with ellipsis menu
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Switch language
                        Button(action: {
                            isEnglishToSerbian.toggle()
                        }) {
                            Label(
                                isEnglishToSerbian ? "Српски" : "English",
                                systemImage: "arrow.left.arrow.right"
                            )
                        }

                        // Toggle Word of the Day
                        Button(action: {
                            withAnimation {
                                showWordOfDay.toggle()
                            }
                        }) {
                            Label(
                                isEnglishToSerbian ?
                                    (showWordOfDay ? "Hide Word of the Day" : "Show Word of the Day") :
                                    (showWordOfDay ? "Сакриј Реч Дана" : "Прикажи Реч Дана"),
                                systemImage: "calendar.badge.clock"
                            )
                        }

                        // Add more options later if needed
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 22))
                    }
                }

                // BOTTOM BAR: Stays unchanged
                ToolbarItem(placement: .bottomBar) {
                    AlphabetBarView(
                        isEnglishToSerbian: isEnglishToSerbian,
                        selectedLetter: Binding(
                            get: { selectedLetter },
                            set: { setSelectedLetter($0) }
                        )
                    )
                }
            }

            .sheet(item: $selectedEntry) { entry in
                NavigationView {
                    WordDetailView(entry: entry, isEnglishToSerbian: isEnglishToSerbian)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .overlay(alignment: .top) {
            if showUpdateToast {
                UpdateToast(count: updateCount, isEnglish: isEnglishToSerbian)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            loadDictionary()
            notificationHandler.onEntrySelected = { entry in
                selectedEntry = entry
            }
        }
    }
}

@main
struct DictionaryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    guard url.scheme == "serbdictionary",
                          let host = url.host,
                          host == "word",
                          let idString = url.pathComponents.dropFirst().first,
                          let id = Int64(idString),
                          id > 0 else {
                        return
                    }

                    if let entry = DatabaseManager.shared.loadEntry(byId: id) {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("ShowWordDetail"),
                            object: nil,
                            userInfo: ["entry": entry]
                        )
                    }
                }
        }
    }
}

extension View {
    @ViewBuilder
    func applyGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive())
        } else {
            self
        }
    }
}
