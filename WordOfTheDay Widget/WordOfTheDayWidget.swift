import WidgetKit
import SwiftUI
import SharedDictionary
import SQLite3

// MARK: - Widget Configuration
struct WordOfDayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.serbdictionary.wordofday",
            provider: WordProvider()
        ) { entry in
            WordWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    BackgroundView()
                }
        }
        .configurationDisplayName("Word of the Day")
        .description("Learn a new Serbian word every day.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Background View
struct BackgroundView: View {
    var body: some View {
        ContainerRelativeShape()
            .fill(.background.opacity(0.9))
    }
}

// MARK: - Timeline Provider
struct WordProvider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), word: createPlaceholderEntry(), isShowingEnglish: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        let entry = WordEntry(date: Date(), word: createPlaceholderEntry(), isShowingEnglish: false)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let currentDate = Date()
        let word = DictionaryEntry.wordOfTheDay(from: DatabaseManager.shared.loadEntries()) ?? createPlaceholderEntry()

        var entries: [WordEntry] = []
        for offset in 0..<8 {
            let entryDate = Calendar.current.date(byAdding: .second, value: offset * 3, to: currentDate)!
            let entry = WordEntry(date: entryDate, word: word, isShowingEnglish: offset % 2 == 1)
            entries.append(entry)
        }

        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!)
        let timeline = Timeline(entries: entries, policy: .after(midnight))
        completion(timeline)
    }
    
    private func createPlaceholderEntry() -> DictionaryEntry {
        DictionaryEntry(
            id: 0,
            translation: DictionaryEntry.Translation(
                cyrillic: DictionaryEntry.Cyrillic(
                    word: "књига",
                    part_of_speech: "именица",
                    definition: "писани или штампани текст",
                    example_sentence: "Читам књигу."
                ),
                latin: DictionaryEntry.Latin(
                    word: "knjiga",
                    part_of_speech: "imenica",
                    definition: "pisani ili štampani tekst",
                    example_sentence: "Čitam knjigu."
                ),
                english: DictionaryEntry.English(
                    word: "book",
                    part_of_speech: "noun",
                    definition: "written or printed text",
                    example_sentence: "I am reading a book."
                )
            )
        )
    }
}

// MARK: - Widget Entry
struct WordEntry: TimelineEntry {
    let date: Date
    let word: DictionaryEntry
    let isShowingEnglish: Bool
}

// MARK: - Widget Views
struct WordWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: WordEntry
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            case .accessoryRectangular:
                RectangularWidgetView(entry: entry)
            case .accessoryInline:
                InlineWidgetView(entry: entry)
            @unknown default:
                Text("Unsupported widget family")
            }
        }
    }
}

struct SmallWidgetView: View {
    let entry: WordEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Word of the Day")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            
            if entry.isShowingEnglish {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.word.translation.english.word)
                        .font(.system(size: 24, weight: .bold))
                        .minimumScaleFactor(0.6)
                    Text(entry.word.translation.english.part_of_speech)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.word.translation.cyrillic.word)
                        .font(.system(size: 24, weight: .bold))
                        .minimumScaleFactor(0.6)
                    Text(entry.word.translation.latin.word)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(entry.word.translation.cyrillic.part_of_speech)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
        }
        .padding()
        .containerBackground(for: .widget) { BackgroundView() }
        .animation(.easeInOut(duration: 0.5), value: entry.isShowingEnglish)
    }
}

struct MediumWidgetView: View {
    let entry: WordEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Word of the Day")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                if entry.isShowingEnglish {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.word.translation.english.word)
                            .font(.system(size: 28, weight: .bold))
                        Text(entry.word.translation.english.part_of_speech)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.word.translation.cyrillic.word)
                            .font(.system(size: 28, weight: .bold))
                        Text(entry.word.translation.latin.word)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(entry.word.translation.cyrillic.part_of_speech)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Spacer()
                Text(entry.isShowingEnglish ? entry.word.translation.english.definition : entry.word.translation.cyrillic.definition)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(3)
                Spacer()
            }
        }
        .padding()
        .containerBackground(for: .widget) { BackgroundView() }
        .animation(.easeInOut(duration: 0.5), value: entry.isShowingEnglish)
    }
}

struct LargeWidgetView: View {
    let entry: WordEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Word of the Day")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if entry.isShowingEnglish {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.word.translation.english.word)
                        .font(.system(size: 32, weight: .bold))
                    Text(entry.word.translation.english.part_of_speech)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("Definition")
                        .font(.headline)
                        .padding(.top)
                    Text(entry.word.translation.english.definition)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Example")
                        .font(.headline)
                        .padding(.top)
                    Text(entry.word.translation.english.example_sentence)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.word.translation.cyrillic.word)
                        .font(.system(size: 32, weight: .bold))
                    Text(entry.word.translation.latin.word)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(entry.word.translation.cyrillic.part_of_speech)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("Дефиниција")
                        .font(.headline)
                        .padding(.top)
                    Text(entry.word.translation.cyrillic.definition)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Пример")
                        .font(.headline)
                        .padding(.top)
                    Text(entry.word.translation.cyrillic.example_sentence)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) { BackgroundView() }
        .animation(.easeInOut(duration: 0.5), value: entry.isShowingEnglish)
    }
}

struct RectangularWidgetView: View {
    let entry: WordEntry
    
    var body: some View {
        HStack {
            if entry.isShowingEnglish {
                Text(entry.word.translation.english.word)
                    .font(.system(size: 16, weight: .semibold))
            } else {
                Text(entry.word.translation.cyrillic.word)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .containerBackground(for: .widget) { BackgroundView() }
        .animation(.easeInOut(duration: 0.5), value: entry.isShowingEnglish)
    }
}

struct InlineWidgetView: View {
    let entry: WordEntry
    
    var body: some View {
        Group {
            if entry.isShowingEnglish {
                Text(entry.word.translation.english.word)
            } else {
                Text(entry.word.translation.latin.word)
            }
        }
        .containerBackground(for: .widget) { BackgroundView() }
    }
}

// MARK: - Widget Bundle
@main
struct WordOfDayWidgetBundle: WidgetBundle {
    var body: some Widget {
        WordOfDayWidget()
    }
}
