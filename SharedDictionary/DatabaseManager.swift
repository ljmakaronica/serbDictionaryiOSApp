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
                    print("Successfully opened database from app group container")
                    return
                }
            }
            
            // If not in container, copy from main bundle
            if let bundleDBPath = Bundle.main.path(forResource: "dictionary", ofType: "db") {
                do {
                    try FileManager.default.copyItem(atPath: bundleDBPath, toPath: dbPath)
                    if sqlite3_open(dbPath, &db) == SQLITE_OK {
                        print("Successfully copied and opened database in app group container")
                        return
                    }
                } catch {
                    print("Error copying database to container: \(error)")
                }
            }
        }
        
        // Fallback to bundle database if app group access fails
        if let bundleDBPath = Bundle.main.path(forResource: "dictionary", ofType: "db") {
            if sqlite3_open(bundleDBPath, &db) == SQLITE_OK {
                print("Successfully opened database from bundle")
            } else {
                print("Error opening database")
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
            print("Error preparing statement")
            return []
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            
            let cyrillicWord = String(cString: sqlite3_column_text(statement, 1))
            let cyrillicPart = String(cString: sqlite3_column_text(statement, 2))
            let cyrillicDef = String(cString: sqlite3_column_text(statement, 3))
            let cyrillicExample = String(cString: sqlite3_column_text(statement, 4))
            
            let latinWord = String(cString: sqlite3_column_text(statement, 5))
            let latinPart = String(cString: sqlite3_column_text(statement, 6))
            let latinDef = String(cString: sqlite3_column_text(statement, 7))
            let latinExample = String(cString: sqlite3_column_text(statement, 8))
            
            let englishWord = String(cString: sqlite3_column_text(statement, 9))
            let englishPart = String(cString: sqlite3_column_text(statement, 10))
            let englishDef = String(cString: sqlite3_column_text(statement, 11))
            let englishExample = String(cString: sqlite3_column_text(statement, 12))
            
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
