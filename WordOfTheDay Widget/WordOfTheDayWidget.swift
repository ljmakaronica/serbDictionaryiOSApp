import SwiftUI
import WidgetKit
import SharedDictionary

struct WordOfDayWidget: View {
    let entry: DictionaryEntry
    
    var body: some View {
        Link(destination: URL(string: "serbiandict://word/\(entry.id)")!) {
            VStack {
                VStack(alignment: .leading) {
                    // Cyrillic
                    Text(entry.translation.cyrillic.word)
                        .font(.system(size: 24, weight: .bold))
                    Spacer().frame(height: 2)
                    // Latin
                    Text(entry.translation.latin.word)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer().frame(height: 12)
                    // English
                    Text(entry.translation.english.word)
                        .font(.system(size: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), entry: loadPlaceholderEntry())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), entry: loadWordOfDay())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(date: Date(), entry: loadWordOfDay())
        let nextUpdate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadWordOfDay() -> DictionaryEntry {
        let entries = DatabaseManager.shared.loadEntries()
        return DictionaryEntry.wordOfTheDay(from: entries) ?? loadPlaceholderEntry()
    }
    
    private func loadPlaceholderEntry() -> DictionaryEntry {
        DictionaryEntry(
            id: 1,
            translation: .init(
                cyrillic: .init(
                    word: "здраво",
                    part_of_speech: "узвик",
                    definition: "поздрав",
                    example_sentence: "Здраво, како си?"
                ),
                latin: .init(
                    word: "zdravo",
                    part_of_speech: "uzvik",
                    definition: "pozdrav",
                    example_sentence: "Zdravo, kako si?"
                ),
                english: .init(
                    word: "hello",
                    part_of_speech: "exclamation",
                    definition: "greeting",
                    example_sentence: "Hello, how are you?"
                )
            )
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let entry: DictionaryEntry
}

@main
struct SerbianDictionaryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.yourdomain.wordofday",
            provider: Provider()
        ) { entry in
            WordOfDayWidget(entry: entry.entry)
        }
        .configurationDisplayName("Word of the Day")
        .description("Learn a new Serbian word daily")
        .supportedFamilies([.systemSmall])
    }
}
