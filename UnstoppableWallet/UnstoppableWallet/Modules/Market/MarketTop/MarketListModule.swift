import Foundation

struct MarketListModule {

    static func topView() -> MarketTopView {
        let dataSource = MarketListTopDataSource(rateManager: App.shared.rateManager)
        let service = MarketTopService(dataSource: dataSource, currencyKit: App.shared.currencyKit)
        let viewModel = MarketTopViewModel(service: service)

        return MarketTopView(viewModel: viewModel)
    }

    static func favoritesView() -> MarketTopView {
        let dataSource = MarketListFavoritesDataSource(rateManager: App.shared.rateManager, favoritesManager: App.shared.marketFavoritesManager)
        let service = MarketTopService(dataSource: dataSource, currencyKit: App.shared.currencyKit)
        let viewModel = MarketTopViewModel(service: service)

        return MarketTopView(viewModel: viewModel)
    }

}
