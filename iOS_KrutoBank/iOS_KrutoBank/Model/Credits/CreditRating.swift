import Foundation

struct CreditRating {
    let userId: String
    let score: Int
    let activeLoans: Int
    let overduePayments: Int

    var hasOverduePayments: Bool { overduePayments > 0 }

    var rating: RatingLevel {
        switch score {
        case 80...100: return .excellent
        case 60..<80:  return .good
        case 40..<60:  return .average
        default:       return .poor
        }
    }

    var description: String {
        switch rating {
        case .excellent: return "Высокая вероятность возврата"
        case .good:      return "Хорошая кредитная история"
        case .average:   return "Средний уровень надёжности"
        case .poor:      return "Высокий риск невозврата"
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
    }
}
