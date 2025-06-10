import Foundation
import SwiftUI

@MainActor
final class CoinListViewModel: ObservableObject {
    private let service: CoinFetcher
    @Published var coins: [CoinSimple] = []
    private(set) var allCoins: [CoinSimple] = []
    private let pageSize = 20
    private var currentIndex: Int = 0

    init(service: CoinFetcher) {
        self.service = service
    }

    func loadCoins() async {
        do {
            allCoins = try await service.fetchAllPrices()
            coins = Array(allCoins.prefix(pageSize))
            currentIndex = coins.count
        } catch {
            BCLogger.log(error.localizedDescription)
        }
    }

    func loadMoreIfNeeded(currentItem: CoinSimple?) {
        guard let currentItem else { return }
        guard let last = coins.last, currentItem.id == last.id else { return }
        let nextIndex = min(currentIndex + pageSize, allCoins.count)
        if currentIndex < nextIndex {
            let newItems = allCoins[currentIndex..<nextIndex]
            coins.append(contentsOf: newItems)
            currentIndex = nextIndex
        }
    }
}
