import Foundation

/// Manages remote dictionary updates from GitHub
public class UpdateManager {
    public static let shared = UpdateManager()

    private let updateURL = URL(string: "https://raw.githubusercontent.com/ljmakaronica/serbian-dictionary-updates/main/updates.json")!
    private let versionKey = "dictionary_update_version"

    private init() {}

    /// Check for and apply any pending updates
    /// Call this on app launch
    /// Returns the number of entries updated, or 0 if none/failed
    @discardableResult
    public func checkForUpdates() async -> Int {
        do {
            let remoteData = try await fetchUpdates()

            let currentVersion = UserDefaults.standard.integer(forKey: versionKey)

            guard remoteData.version > currentVersion else {
                #if DEBUG
                print("UpdateManager: Already up to date (v\(currentVersion))")
                #endif
                return 0
            }

            #if DEBUG
            print("UpdateManager: Updating from v\(currentVersion) to v\(remoteData.version)")
            #endif

            // Apply each update entry
            for entry in remoteData.entries {
                applyUpdate(entry)
            }

            // Save new version
            UserDefaults.standard.set(remoteData.version, forKey: versionKey)

            #if DEBUG
            print("UpdateManager: Successfully applied \(remoteData.entries.count) updates")
            #endif

            return remoteData.entries.count

        } catch {
            #if DEBUG
            print("UpdateManager: Failed to check for updates - \(error.localizedDescription)")
            #endif
            return 0
        }
    }

    private func fetchUpdates() async throws -> UpdatePayload {
        var request = URLRequest(url: updateURL)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw UpdateError.networkError
        }

        let decoder = JSONDecoder()
        return try decoder.decode(UpdatePayload.self, from: data)
    }

    private func applyUpdate(_ entry: UpdateEntry) {
        switch entry.action {
        case .add:
            DatabaseManager.shared.insertEntry(entry)
        case .update:
            DatabaseManager.shared.updateEntry(entry)
        case .delete:
            if let id = entry.id {
                DatabaseManager.shared.deleteEntry(id: id)
            }
        }
    }
}

// MARK: - Models

struct UpdatePayload: Codable {
    let version: Int
    let entries: [UpdateEntry]
}

public struct UpdateEntry: Codable {
    public let action: UpdateAction
    public let id: Int64?

    // All fields optional for partial updates
    public let cyrillic_word: String?
    public let cyrillic_part: String?
    public let cyrillic_def: String?
    public let cyrillic_example: String?

    public let latin_word: String?
    public let latin_part: String?
    public let latin_def: String?
    public let latin_example: String?

    public let english_word: String?
    public let english_part: String?
    public let english_def: String?
    public let english_example: String?
}

public enum UpdateAction: String, Codable {
    case add
    case update
    case delete
}

enum UpdateError: Error {
    case networkError
    case parseError
}
