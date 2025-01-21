import SwiftUI

// MARK: - Models
public struct DictionaryEntry: Identifiable {
   public let id: Int64
   public let translation: Translation
   
   public init(id: Int64, translation: Translation) {
       self.id = id
       self.translation = translation
   }
   
   public struct Translation {
       public let cyrillic: Cyrillic
       public let latin: Latin
       public let english: English
       
       public init(cyrillic: Cyrillic, latin: Latin, english: English) {
           self.cyrillic = cyrillic
           self.latin = latin
           self.english = english
       }
   }
   
   public struct Cyrillic {
       public let word: String
       public let part_of_speech: String
       public let definition: String
       public let example_sentence: String
       
       public init(word: String, part_of_speech: String, definition: String, example_sentence: String) {
           self.word = word
           self.part_of_speech = part_of_speech
           self.definition = definition
           self.example_sentence = example_sentence
       }
   }
   
   public struct Latin {
       public let word: String
       public let part_of_speech: String
       public let definition: String
       public let example_sentence: String
       
       public init(word: String, part_of_speech: String, definition: String, example_sentence: String) {
           self.word = word
           self.part_of_speech = part_of_speech
           self.definition = definition
           self.example_sentence = example_sentence
       }
   }
   
   public struct English {
       public let word: String
       public let part_of_speech: String
       public let definition: String
       public let example_sentence: String
       
       public init(word: String, part_of_speech: String, definition: String, example_sentence: String) {
           self.word = word
           self.part_of_speech = part_of_speech
           self.definition = definition
           self.example_sentence = example_sentence
       }
   }
   
   // Pre-determined random sequence of indices for 365 days
   public static let dailyIndices = [
       221, 131, 311, 297, 165, 183, 38, 221, 344, 162,
       455, 296, 83, 51, 356, 369, 110, 331, 37, 318,
       383, 111, 303, 454, 11, 465, 204, 136, 134, 183,
       360, 370, 70, 38, 14, 398, 465, 311, 48, 207,
       438, 191, 233, 100, 196, 341, 145, 63, 345, 485,
       417, 202, 266, 179, 116, 175, 7, 464, 260, 67,
       377, 176, 184, 261, 310, 361, 358, 152, 181, 364,
       144, 461, 250, 408, 321, 140, 102, 207, 66, 43,
       167, 365, 106, 76, 122, 63, 453, 39, 281, 263,
       345, 239, 267, 469, 411, 348, 253, 428, 15, 230,
       400, 236, 14, 179, 134, 240, 22, 94, 451, 308,
       450, 465, 491, 386, 465, 151, 142, 328, 250, 246,
       386, 407, 392, 154, 440, 226, 94, 347, 28, 252,
       86, 103, 46, 146, 41, 107, 29, 306, 460, 55,
       338, 134, 310, 98, 206, 286, 396, 6, 480, 348,
       258, 236, 346, 231, 109, 249, 382, 375, 157, 134,
       53, 247, 175, 163, 231, 65, 448, 67, 55, 38,
       362, 296, 137, 451, 321, 67, 293, 338, 81, 153,
       158, 322, 485, 98, 378, 393, 410, 430, 472, 96,
       93, 41, 374, 127, 367, 302, 443, 321, 222, 362,
       278, 226, 96, 12, 308, 474, 404, 74, 259, 60,
       247, 279, 469, 237, 221, 162, 108, 100, 256, 249,
       59, 391, 406, 452, 206, 192, 122, 72, 170, 266,
       332, 98, 315, 52, 10, 114, 367, 2, 7, 8,
       376, 215, 189, 472, 272, 361, 146, 302, 151, 215,
       29, 98, 428, 277, 109, 357, 257, 231, 39, 91,
       412, 152, 474, 202, 472, 100, 479, 249, 23, 46,
       193, 138, 318, 211, 94, 282, 210, 141, 291, 114,
       162, 165, 326, 480, 318, 5, 382, 146, 254, 461,
       73, 106, 233, 1, 266, 353, 66, 303, 102, 186,
       431, 10, 45, 288, 336, 125, 100, 423, 272, 203,
       390, 350, 360, 70, 204, 216, 406, 460, 80, 7,
       483, 72, 436, 105, 199, 358, 384, 489, 350, 62,
       201, 361, 224, 456, 151, 483, 403, 494, 281, 187,
       261, 208, 461, 186, 74, 393, 60, 409, 287, 489,
       280, 322, 118, 432, 186, 335, 6, 195, 362, 313,
       398, 9, 282, 126, 383
   ]
   
   public static func wordOfTheDay(from entries: [DictionaryEntry]) -> DictionaryEntry? {
       guard !entries.isEmpty else { return nil }
       
       // Get current day of year
       var calendar = Calendar(identifier: .gregorian)
       calendar.timeZone = TimeZone(identifier: "UTC")!
       let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
       
       // Use the day to look up in our predetermined list
       let index = dailyIndices[(dayOfYear - 1) % dailyIndices.count] % entries.count
       return entries[index]
   }
}
