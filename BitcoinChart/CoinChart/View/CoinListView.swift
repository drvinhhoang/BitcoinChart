import SwiftUI

struct CoinListView: View {
    @StateObject var vm = CoinListViewModel(service: CoinService(requestManager: RequestManager()))

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.coins) { coin in
                    NavigationLink(destination: CoinView(symbol: coin.symbol)) {
                        HStack {
                            Text(coin.symbol)
                            Spacer()
                            Text(coin.price)
                        }
                        .onAppear {
                            vm.loadMoreIfNeeded(currentItem: coin)
                        }
                    }
                }
            }
            .navigationTitle("Coins")
            .task {
                await vm.loadCoins()
            }
        }
    }
}

struct CoinListView_Previews: PreviewProvider {
    static var previews: some View {
        CoinListView()
    }
}
