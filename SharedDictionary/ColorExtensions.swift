import SwiftUI

// MARK: - Color Extension
public extension Color {
   public static let partOfSpeechColors = PartOfSpeechColors()
   
   public struct PartOfSpeechColors {
       public let noun = Color.blue.opacity(0.7)
       public let verb = Color.green.opacity(0.7)
       public let adjective = Color.purple.opacity(0.7)
       public let adverb = Color.orange.opacity(0.7)
       public let conjunction = Color.pink.opacity(0.7)
       public let number = Color.brown.opacity(0.7)
       public let exclamation = Color.cyan.opacity(0.7)
       
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
           case "везник", "veznik", "conjunction":
               return conjunction
           case "број", "broj", "number":
               return number
           case "узвик", "uzvik", "exclamation":
               return exclamation
           default:
               return .secondary
           }
       }
   }
}
