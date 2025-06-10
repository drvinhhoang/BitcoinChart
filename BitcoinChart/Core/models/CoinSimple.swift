import Foundation

struct CoinSimple: Codable, Identifiable {
    let symbol: String
    let price: String

    var id: String { symbol }
}
