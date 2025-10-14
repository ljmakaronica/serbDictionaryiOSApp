import SwiftUI

// MARK: - Color Extension
public extension Color {
   static let partOfSpeechColors = PartOfSpeechColors()
   
    struct PartOfSpeechColors {
       public let noun = Color.blue.opacity(0.75)
       public let verb = Color.green.opacity(0.75)
       public let adjective = Color.purple.opacity(0.75)
       public let adverb = Color.orange.opacity(0.75)
       public let pronoun = Color.red.opacity(0.75)
       public let preposition = Color.teal.opacity(0.75)
       public let conjunction = Color.pink.opacity(0.75)
       public let interjection = Color.yellow.opacity(0.75)
       public let number = Color.brown.opacity(0.75)
       public let particle = Color.indigo.opacity(0.75)

       public init() {} // Add public initializer

       public func colorForPartOfSpeech(_ partOfSpeech: String) -> Color {
           switch partOfSpeech.lowercased() {
           case "именица", "imenica", "noun":
               return noun
           case "глагол", "glagol", "verb":
               return verb
           case "придев", "pridev", "adjective":
               return adjective
           case "прилог", "prilog", "adverb":
               return adverb
           case "заменица", "zamenica", "pronoun":
               return pronoun
           case "предлог", "predlog", "preposition":
               return preposition
           case "везник", "veznik", "conjunction":
               return conjunction
           case "узвик", "uzvik", "interjection":
               return interjection
           case "број", "broj", "number":
               return number
           case "речца", "rečca", "particle":
               return particle
           default:
               return .secondary
           }
       }
   }
}
