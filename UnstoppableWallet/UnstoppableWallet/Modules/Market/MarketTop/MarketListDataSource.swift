import RxSwift
import RxRelay
import XRatesKit

protocol IMarketListDataSource {
    func list(currencyCode: String) -> Single<[TopMarket]>
    var updateListObservable: Observable<()> { get }
}

class MarketListTopDataSource {
    private let rateManager: IRateManager

    init(rateManager: IRateManager) {
        self.rateManager = rateManager
    }

}

extension MarketListTopDataSource: IMarketListDataSource {

    func list(currencyCode: String) -> Single<[TopMarket]> {
        rateManager.topMarketInfos(currencyCode: currencyCode)
    }

    var updateListObservable: Observable<()> {
        Observable.just(())
    }
}

class MarketListFavoritesDataSource {
    private let rateManager: IRateManager
    private let favoritesManager: MarketFavoritesManager

    private let disposeBag = DisposeBag()
    private let updateListRelay = PublishRelay<()>()

    init(rateManager: IRateManager, favoritesManager: MarketFavoritesManager) {
        self.rateManager = rateManager
        self.favoritesManager = favoritesManager

        subscribe(disposeBag, favoritesManager.updateObservable) { [weak self] in self?.updateListRelay.accept(()) }
    }

}

extension MarketListFavoritesDataSource: IMarketListDataSource {

    func list(currencyCode: String) -> Single<[TopMarket]> {
        let favorites = favoritesManager.all()
        //todo: get favorites by coinCodes
        return Single.just([])
    }

    var updateListObservable: Observable<()> {
        updateListRelay.asObservable()
    }

}
