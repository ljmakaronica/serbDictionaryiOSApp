import Foundation
import SQLite3

public enum DatabaseError: Error {
    case setupFailed(String)
    case notInitialized
    case queryFailed(String)
}

public class DatabaseManager {
    public static let shared = DatabaseManager()
    private var db: OpaquePointer?

    public private(set) var isReady: Bool = false
    public private(set) var lastError: String?

    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        // First try to get the database from the app group container
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.serbdictionary.identifier") {
            let dbPath = containerURL.appendingPathComponent("dictionary.db").path

            // Check if database exists in container
            if FileManager.default.fileExists(atPath: dbPath) {
                if sqlite3_open(dbPath, &db) == SQLITE_OK {
                    isReady = true
                    #if DEBUG
                    print("Successfully opened database from app group container")
                    #endif
                    return
                }
            }

            // If not in container, copy from main bundle
            if let bundleDBPath = Bundle.main.path(forResource: "dictionary", ofType: "db") {
                do {
                    try FileManager.default.copyItem(atPath: bundleDBPath, toPath: dbPath)
                    if sqlite3_open(dbPath, &db) == SQLITE_OK {
                        isReady = true
                        #if DEBUG
                        print("Successfully copied and opened database in app group container")
                        #endif
                        return
                    } else {
                        lastError = "Failed to open database after copying"
                    }
                } catch {
                    lastError = "Failed to copy database: \(error.localizedDescription)"
                    #if DEBUG
                    print("Error copying database to container: \(error)")
                    #endif
                }
            } else {
                lastError = "Database file not found in app bundle"
            }
        } else {
            lastError = "Failed to access app group container"
        }

        // Fallback to bundle database if app group access fails
        if let bundleDBPath = Bundle.main.path(forResource: "dictionary", ofType: "db") {
            if sqlite3_open(bundleDBPath, &db) == SQLITE_OK {
                isReady = true
                lastError = nil // Clear any previous error
                #if DEBUG
                print("Successfully opened database from bundle")
                #endif
            } else {
                lastError = "Failed to open database from bundle"
                #if DEBUG
                print("Error opening database")
                #endif
                db = nil
            }
        } else if !isReady {
            lastError = "Database file not found anywhere"
        }
    }
    
    // Helper function to safely extract strings
    private func safeString(from statement: OpaquePointer?, column: Int32) -> String {
        guard let cString = sqlite3_column_text(statement, column) else {
            return ""
        }
        return String(cString: cString)
    }

    // Helper function to create entry from statement row
    private func createEntry(from statement: OpaquePointer?) -> DictionaryEntry? {
        let id = sqlite3_column_int64(statement, 0)

        let cyrillicWord = safeString(from: statement, column: 1)
        let cyrillicPart = safeString(from: statement, column: 2)
        let cyrillicDef = safeString(from: statement, column: 3)
        let cyrillicExample = safeString(from: statement, column: 4)

        let latinWord = safeString(from: statement, column: 5)
        let latinPart = safeString(from: statement, column: 6)
        let latinDef = safeString(from: statement, column: 7)
        let latinExample = safeString(from: statement, column: 8)

        let englishWord = safeString(from: statement, column: 9)
        let englishPart = safeString(from: statement, column: 10)
        let englishDef = safeString(from: statement, column: 11)
        let englishExample = safeString(from: statement, column: 12)

        return DictionaryEntry(
            id: id,
            translation: .init(
                cyrillic: .init(
                    word: cyrillicWord,
                    part_of_speech: cyrillicPart,
                    definition: cyrillicDef,
                    example_sentence: cyrillicExample
                ),
                latin: .init(
                    word: latinWord,
                    part_of_speech: latinPart,
                    definition: latinDef,
                    example_sentence: latinExample
                ),
                english: .init(
                    word: englishWord,
                    part_of_speech: englishPart,
                    definition: englishDef,
                    example_sentence: englishExample
                )
            )
        )
    }

    // Load entries starting with a specific letter (for progressive loading)
    public func loadEntries(startingWith letter: String, isEnglish: Bool) -> [DictionaryEntry] {
        guard isReady else {
            #if DEBUG
            print("Database not ready, cannot load entries")
            #endif
            return []
        }

        var entries: [DictionaryEntry] = []

        let columnName = isEnglish ? "english_word" : "cyrillic_word"
        let queryString = """
            SELECT id,
                   cyrillic_word, cyrillic_part, cyrillic_def, cyrillic_example,
                   latin_word, latin_part, latin_def, latin_example,
                   english_word, english_part, english_def, english_example
            FROM words
            WHERE UPPER(\(columnName)) LIKE ?
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK else {
            #if DEBUG
            print("Error preparing statement for letter filter")
            #endif
            return []
        }

        let pattern = "\(letter.uppercased())%"
        sqlite3_bind_text(statement, 1, (pattern as NSString).utf8String, -1, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            if let entry = createEntry(from: statement) {
                entries.append(entry)
            }
        }

        sqlite3_finalize(statement)
        return entries
    }

    // Load a specific entry by ID (for Word of the Day)
    public func loadEntry(byId id: Int64) -> DictionaryEntry? {
        guard isReady else {
            #if DEBUG
            print("Database not ready, cannot load entry")
            #endif
            return nil
        }

        let queryString = """
            SELECT id,
                   cyrillic_word, cyrillic_part, cyrillic_def, cyrillic_example,
                   latin_word, latin_part, latin_def, latin_example,
                   english_word, english_part, english_def, english_example
            FROM words
            WHERE id = ?
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK else {
            #if DEBUG
            print("Error preparing statement for ID lookup")
            #endif
            return nil
        }

        sqlite3_bind_int64(statement, 1, id)

        var entry: DictionaryEntry?
        if sqlite3_step(statement) == SQLITE_ROW {
            entry = createEntry(from: statement)
        }

        sqlite3_finalize(statement)
        return entry
    }

    public func loadEntries() -> [DictionaryEntry] {
        guard isReady else {
            #if DEBUG
            print("Database not ready, cannot load entries")
            #endif
            return []
        }

        var entries: [DictionaryEntry] = []

        let queryString = """
            SELECT id,
                   cyrillic_word, cyrillic_part, cyrillic_def, cyrillic_example,
                   latin_word, latin_part, latin_def, latin_example,
                   english_word, english_part, english_def, english_example
            FROM words
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK else {
            #if DEBUG
            print("Error preparing statement")
            #endif
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            if let entry = createEntry(from: statement) {
                entries.append(entry)
            }
        }

        sqlite3_finalize(statement)
        return entries
    }
    
    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }
}
