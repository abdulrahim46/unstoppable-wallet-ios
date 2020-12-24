import UIKit
import RxSwift
import RxCocoa
import ThemeKit
import HUD
import SectionsTableView

class MarketFavoritesViewController: ThemeViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: MarketFavoritesViewModel

    private let tableView = SectionsTableView(style: .plain)
    private let marketFavoritesView = MarketListModule.favoritesView()

    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private var isLoading: Bool = false

    init(viewModel: MarketFavoritesViewModel) {
        self.viewModel = viewModel

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.scrollsToTop = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tableView.scrollsToTop = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.scrollsToTop = false

        tableView.sectionDataSource = self

        marketFavoritesView.registeringCellClasses.forEach { tableView.registerCell(forClass: $0) }
        marketFavoritesView.openController = { [weak self] in
            self?.present($0, animated: true)
        }

        subscribe(disposeBag, marketFavoritesView.sectionUpdatedSignal) { [weak self] in self?.tableView.reload() }
        subscribe(disposeBag, marketFavoritesView.isLoadingDriver) { [weak self] in self?.sync(loading: $0) }
        subscribe(disposeBag, marketFavoritesView.errorDriver) { [weak self] in self?.sync(error: $0) }

        tableView.buildSections()
    }

    private func sync(loading: Bool) {
        isLoadingRelay.accept(loading)
    }

    private func sync(error: String?) {

    }

}

extension MarketFavoritesViewController {

    var isLoadingDriver: Driver<Bool> {
        isLoadingRelay.asDriver()
    }

}

extension MarketFavoritesViewController: SectionsDataSource {

    func buildSections() -> [SectionProtocol] {
        [marketFavoritesView.section]
    }

}
