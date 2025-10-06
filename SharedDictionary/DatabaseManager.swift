import Foundation
import SQLite3

public class DatabaseManager {
    public static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
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
                        #if DEBUG
                        print("Successfully copied and opened database in app group container")
                        #endif
                        return
                    }
                } catch {
                    #if DEBUG
                    print("Error copying database to container: \(error)")
                    #endif
                }
            }
        }

        // Fallback to bundle database if app group access fails
        if let bundleDBPath = Bundle.main.path(forResource: "dictionary", ofType: "db") {
            if sqlite3_open(bundleDBPath, &db) == SQLITE_OK {
                #if DEBUG
                print("Successfully opened database from bundle")
                #endif
            } else {
                #if DEBUG
                print("Error opening database")
                #endif
                db = nil
            }
        }
    }
    
    public func loadEntries() -> [DictionaryEntry] {
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
        
        // Helper function to safely extract strings
        func safeString(from statement: OpaquePointer?, column: Int32) -> String {
            guard let cString = sqlite3_column_text(statement, column) else {
                return ""
            }
            return String(cString: cString)
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
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
            
            let entry = DictionaryEntry(
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
            
            entries.append(entry)
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
