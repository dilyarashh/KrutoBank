struct CreditRating {
    let userId: String
    let score: Int
    let activeLoans: Int
    let overduePayments: Int

    var scoreLabel: String {
        switch score {
        case 80...100:
            return "Отличный"
        case 60..<80: 
            return "Хороший"
        case 40..<60:  
            return "Средний"
        case 20..<40: 
            return "Плохой"
        default:      
            return "Очень плохой"
        }
    }

    var hasOverduePayments: Bool {
        overduePayments > 0
    }
}
