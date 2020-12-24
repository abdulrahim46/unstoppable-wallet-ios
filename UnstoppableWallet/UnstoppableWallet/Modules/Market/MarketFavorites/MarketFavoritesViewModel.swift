import Foundation
import RxSwift
import RxRelay
import RxCocoa

class MarketFavoritesViewModel {
    private let disposeBag = DisposeBag()
    private let service: MarketFavoritesService

    init(service: MarketFavoritesService) {
        self.service = service
    }

}

extension MarketFavoritesViewModel {
}
