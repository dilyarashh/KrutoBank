import Foundation

struct CreditRatingResponse: Decodable {
    let userId: String
    let score: Int          // 0–100
    let description: String // e.g. "Отличный", "Хороший", "Плохой"

    var rating: RatingLevel {
        switch score {
        case 80...100: return .excellent
        case 60..<80:  return .good
        case 40..<60:  return .average
        default:        return .poor
        }
    }

    enum RatingLevel {
        case excellent, good, average, poor

        var label: String {
            switch self {
            case .excellent: return "Отличный"
            case .good:      return "Хороший"
            case .average:   return "Средний"
            case .poor:      return "Плохой"
            }
        }

        var color: String {
            switch self {
            case .excellent: return "textSuccess"
            case .good:      return "primaryPink"
            case .average:   return "textWarning"
            case .poor:      return "textError"
            }
        }
    }
}
