import Foundation
import RxSwift
import RxRelay

class MarketFavoritesManager {
    private let localStorage: ILocalStorage

    private let updateListRelay = PublishRelay<()>()

    init(localStorage: ILocalStorage) {
        self.localStorage = localStorage
    }

}

extension MarketFavoritesManager {

    public func all() -> [FavoriteCoin] {
        localStorage.marketFavoriteCoins
    }

    public func add(coinCode: String) {
        var all = localStorage.marketFavoriteCoins
        guard all.first(where: { $0.code == coinCode }) == nil else {
            return
        }
        all.append(FavoriteCoin(code: coinCode))

        localStorage.marketFavoriteCoins = all
        updateListRelay.accept(())
    }

    public func remove(coinCode: String) {
        var all = localStorage.marketFavoriteCoins
        if let index = all.firstIndex(where: { coin in coin.code == coinCode }) {
            all.remove(at: index)
        }

        localStorage.marketFavoriteCoins = all
        updateListRelay.accept(())
    }

    public func isFavorite(coinCode: String) -> Bool {
        localStorage.marketFavoriteCoins.contains { coin in coin.code == coinCode }
    }

    public var updateObservable: Observable<()> {
        updateListRelay.asObservable()
    }

}

extension MarketFavoritesManager {

    struct FavoriteCoin {
        let code: String
    }

}
