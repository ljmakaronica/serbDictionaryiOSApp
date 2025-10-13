import SwiftUI
import WidgetKit
import SharedDictionary

struct WordOfDayWidget: View {
    let entry: DictionaryEntry

    var body: some View {
        if let url = URL(string: "serbdictionary://word/\(entry.id)") {
            Link(destination: url) {
                widgetContent
            }
        } else {
            widgetContent
        }
    }

    private var widgetContent: some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                // Word container
                VStack(alignment: .leading, spacing: 2) {
                    // Cyrillic - resize to fit
                    Text(entry.translation.cyrillic.word)
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Latin - smaller and secondary
                    Text(entry.translation.latin.word)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer(minLength: 6)
                
                // Translation container
                VStack(alignment: .leading, spacing: 2) {
                    // English translation
                    Text(entry.translation.english.word)
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(for: .widget) {
                Color(uiColor: .systemBackground)
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
        guard DatabaseManager.shared.isReady else {
            return loadPlaceholderEntry()
        }
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
            kind: "com.Marko.serbDictionary.wordofday",
            provider: Provider()
        ) { entry in
            WordOfDayWidget(entry: entry.entry)
        }
        .configurationDisplayName("Word of the Day")
        .description("Learn a new Serbian word daily")
        .supportedFamilies([.systemSmall])
    }
}
