import UIKit
import SnapKit
import ThemeKit
import SectionsTableView
import HUD
import RxSwift
import RxCocoa

class MarketViewController: ThemeSearchViewController {
    private let disposeBag = DisposeBag()

    private let viewModel: MarketViewModel

    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var viewControllers = [UIViewController]()

    private let categoriesHeaderView: MarketCategoriesView
    private let syncSpinner = HUDProgressView(
            strokeLineWidth: 2,
            radius: 9,
            strokeColor: .themeGray,
            duration: 2
    )

    init(viewModel: MarketViewModel) {
        self.viewModel = viewModel

        categoriesHeaderView = MarketCategoriesModule.view(service: viewModel.categoriesService)

        super.init()

        title = "market.title".localized
        tabBarItem = UITabBarItem(title: "market.tab_bar_item".localized, image: UIImage(named: "market_2_24"), tag: 0)

        let router = LockScreenRouter(appStart: false)

        viewControllers.append(MarketTop100Module.view(service: MarketTop100Service()))
        viewControllers.append(MarketWatchlistModule.view(service: MarketWatchlistService()))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(categoriesHeaderView)
        categoriesHeaderView.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(40)
        }

        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { maker in
            maker.top.equalTo(categoriesHeaderView.snp.bottom)
            maker.leading.trailing.equalToSuperview()
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        syncPageViewController()
        subscribe(disposeBag, viewModel.updateCategorySignal) { [weak self] in self?.syncPageViewController() }
    }

    private func syncPageViewController() {
        pageViewController.setViewControllers([viewControllers[viewModel.currentCategoryIndex]], direction: .forward, animated: false)
    }

}