import UIKit
import RxSwift
import XRatesKit

class ChartInteractor {
    weak var delegate: IChartInteractorDelegate?

    private let disposeBag = DisposeBag()
    private var chartsDisposeBag = DisposeBag()

    private let rateManager: IRateManager
    private let chartTypeStorage: IChartTypeStorage
    private let currentDateProvider: ICurrentDateProvider
    private let priceAlertManager: IPriceAlertManager
    private let localStorage: ILocalStorage
    private let favoritesManager: MarketFavoritesManager

    init(rateManager: IRateManager, chartTypeStorage: IChartTypeStorage, currentDateProvider: ICurrentDateProvider, priceAlertManager: IPriceAlertManager, localStorage: ILocalStorage, favoritesManager: MarketFavoritesManager) {
        self.rateManager = rateManager
        self.chartTypeStorage = chartTypeStorage
        self.currentDateProvider = currentDateProvider
        self.priceAlertManager = priceAlertManager
        self.localStorage = localStorage
        self.favoritesManager = favoritesManager
    }

}

extension ChartInteractor: IChartInteractor {

    var defaultChartType: ChartType? {
        get {
            chartTypeStorage.chartType
        }
        set {
            chartTypeStorage.chartType = newValue
        }
    }

    var alertsOn: Bool {
        localStorage.pushNotificationsOn
    }

    func chartInfo(coinCode: CoinCode, currencyCode: String, chartType: ChartType) -> ChartInfo? {
        rateManager.chartInfo(coinCode: coinCode, currencyCode: currencyCode, chartType: chartType)
    }

    func subscribeToChartInfo(coinCode: CoinCode, currencyCode: String, chartType: ChartType) {
        chartsDisposeBag = DisposeBag()

        rateManager.chartInfoObservable(coinCode: coinCode, currencyCode: currencyCode, chartType: chartType)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] chartInfo in
                    self?.delegate?.didReceive(chartInfo: chartInfo, coinCode: coinCode)
                }, onError: { [weak self] error in
                    self?.delegate?.onChartInfoError(error: error)
                })
                .disposed(by: chartsDisposeBag)
    }

    func marketInfo(coinCode: CoinCode, currencyCode: String) -> MarketInfo? {
        rateManager.marketInfo(coinCode: coinCode, currencyCode: currencyCode)
    }

    func subscribeToMarketInfo(coinCode: CoinCode, currencyCode: String) {
        rateManager.marketInfoObservable(coinCode: coinCode, currencyCode: currencyCode)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] marketInfo in
                    self?.delegate?.didReceive(marketInfo: marketInfo)
                })
                .disposed(by: disposeBag)
    }

    func priceAlert(coin: Coin?) -> PriceAlert? {
        guard let coin = coin else {
            return nil
        }

        return priceAlertManager.priceAlert(coin: coin)
    }

    func isFavorite(coinCode: String) -> Bool {
        favoritesManager.isFavorite(coinCode: coinCode)
    }

    func addFavorite(coinCode: String) {
        favoritesManager.add(coinCode: coinCode)

        delegate?.didUpdateFavorite()
    }

    func removeFavorite(coinCode: String) {
        favoritesManager.remove(coinCode: coinCode)

        delegate?.didUpdateFavorite()
    }

    func subscribeToAlertUpdates() {
        priceAlertManager.updateObservable
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] alerts in
                    self?.delegate?.didUpdate(alerts: alerts)
                })
                .disposed(by: disposeBag)
    }

}
