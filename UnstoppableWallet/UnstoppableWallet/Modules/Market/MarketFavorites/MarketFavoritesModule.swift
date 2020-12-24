import Foundation

struct MarketFavoritesModule {

    static func view(service: MarketFavoritesService) -> MarketFavoritesViewController {
        let viewModel = MarketFavoritesViewModel(service: service)

        return MarketFavoritesViewController(viewModel: viewModel)
    }

}
