import SwiftUI
import SharedDictionary
struct WordDetailView: View {
    let entry: DictionaryEntry
    let isEnglishToSerbian: Bool
    @Environment(\.dismiss) var dismiss
    @State private var appear = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header with close button
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.secondary)
                                .padding(.trailing)
                                .padding(.top, 8)
                        }
                    }

                    VStack(spacing: 24) {
                        if isEnglishToSerbian {
                            englishCard
                            divider
                            serbianCard
                        } else {
                            serbianCard
                            divider
                            englishCard
                        }

                        Button(action: {
                            openGoogleForm(for: entry)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.bubble")
                                Text(isEnglishToSerbian ? "Report Inaccuracy" : "Prijavi grešku")
                            }
                            .foregroundColor(.blue)
                            .font(.system(size: 15, weight: .medium))
                        }
                        .padding(.top, 24)
                    }
                    .padding(20)
                }
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 50)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                appear = true
            }
        }
    }
    
    func openGoogleForm(for entry: DictionaryEntry) {
        let englishWord = entry.translation.english.word
        let cyrillicWord = entry.translation.cyrillic.word
        let latinWord = entry.translation.latin.word
        
        let combinedWords = "\(englishWord) | \(latinWord) | \(cyrillicWord)"
        
        let encodedWords = combinedWords.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let baseURL = "https://docs.google.com/forms/d/e/1FAIpQLSdyreBT6WKa3szYCExehtf3VR9Qk7idpi4ISbgnWJZkgVLiUw/viewform"
        
        let urlString = "\(baseURL)?usp=pp_url&entry.1466278060=\(encodedWords)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.2))
            .frame(height: 1)
            .padding(.horizontal, 32)
    }
    
    private var englishCard: some View {
            WordCard(
                word: entry.translation.english.word,
                partOfSpeech: entry.translation.english.part_of_speech,
                definition: entry.translation.english.definition,
                exampleSentence: entry.translation.english.example_sentence,
                language: .english
            )
        }
        
        private var serbianCard: some View {
            WordCard(
                cyrillic: entry.translation.cyrillic,
                latin: entry.translation.latin,
                language: .serbian
            )
        }
    }

enum Language {
    case english
    case serbian
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .serbian: return "🇷🇸"
        }
    }
    
    var label: String {
        switch self {
        case .english: return "English"
        case .serbian: return "Српски"
        }
    }
    
    var definitionLabel: String {
        switch self {
        case .english: return "Definition:"
        case .serbian: return "Дефиниција:"
        }
    }
    
    var exampleLabel: String {
        switch self {
        case .english: return "Example:"
        case .serbian: return "Пример:"
        }
    }
}

struct WordCard: View {
    // For English card
    let word: String?
    let partOfSpeech: String?
    let definition: String?
    let exampleSentence: String?
    
    // For Serbian card
    let cyrillic: DictionaryEntry.Cyrillic?
    let latin: DictionaryEntry.Latin?
    
    let language: Language
    @State private var selectedScript: Script = .cyrillic
    
    enum Script {
        case cyrillic, latin
        
        var title: String {
            switch self {
            case .cyrillic: return "Ћирилица"
            case .latin: return "Latinica"
            }
        }
    }
    
    // Initialize for English
    init(word: String, partOfSpeech: String, definition: String, exampleSentence: String, language: Language) {
        self.word = word
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.exampleSentence = exampleSentence
        self.language = language
        self.cyrillic = nil
        self.latin = nil
    }
    
    // Initialize for Serbian
    init(cyrillic: DictionaryEntry.Cyrillic, latin: DictionaryEntry.Latin, language: Language) {
        self.cyrillic = cyrillic
        self.latin = latin
        self.language = language
        self.word = nil
        self.partOfSpeech = nil
        self.definition = nil
        self.exampleSentence = nil
    }
    
    var currentWord: String {
        switch language {
        case .english:
            return word ?? ""
        case .serbian:
            return selectedScript == .cyrillic ? cyrillic?.word ?? "" : latin?.word ?? ""
        }
    }
    
    var currentPartOfSpeech: String {
        switch language {
        case .english:
            return partOfSpeech ?? ""
        case .serbian:
            return selectedScript == .cyrillic ? cyrillic?.part_of_speech ?? "" : latin?.part_of_speech ?? ""
        }
    }
    
    var currentDefinition: String {
        switch language {
        case .english:
            return definition ?? ""
        case .serbian:
            return selectedScript == .cyrillic ? cyrillic?.definition ?? "" : latin?.definition ?? ""
        }
    }
    
    var currentExample: String {
        switch language {
        case .english:
            return exampleSentence ?? ""
        case .serbian:
            return selectedScript == .cyrillic ? cyrillic?.example_sentence ?? "" : latin?.example_sentence ?? ""
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Text(language.flag)
                    .font(.system(size: 24))
                Text(language.label)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
            }

            // Script switcher (Serbian only)
            if case .serbian = language {
                HStack(spacing: 0) {
                    ForEach([Script.cyrillic, Script.latin], id: \.self) { script in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedScript = script
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(script.title)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedScript == script ? .primary : .secondary)

                                Rectangle()
                                    .fill(selectedScript == script ? Color.blue : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            // Word
            Text(currentWord)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)

            // Part of Speech
            Text(currentPartOfSpeech)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.partOfSpeechColors.colorForPartOfSpeech(currentPartOfSpeech))
                )

            // Definition
            VStack(alignment: .leading, spacing: 4) {
                Text(language == .english ? language.definitionLabel : (selectedScript == .cyrillic ? "Дефиниција:" : "Definicija:"))
                    .font(.system(size: 15, weight: .semibold))
                Text(currentDefinition)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }

            // Example
            VStack(alignment: .leading, spacing: 4) {
                Text(language == .english ? language.exampleLabel : (selectedScript == .cyrillic ? "Пример:" : "Primer:"))
                    .font(.system(size: 15, weight: .semibold))
                Text(currentExample)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
