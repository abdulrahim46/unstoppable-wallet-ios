import UIKit
import SnapKit
import ThemeKit
import SectionsTableView
import HUD
import RxSwift
import RxCocoa

class MarketViewController: ThemeViewController {
    private let disposeBag = DisposeBag()

    private let viewModel: MarketViewModel

    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var viewControllers = [UIViewController]()

    private let categoriesHeaderView: MarketCategoriesView
    private let loadingSpinner = HUDActivityView.create(with: .medium24)

    init(viewModel: MarketViewModel) {
        self.viewModel = viewModel

        categoriesHeaderView = MarketCategoriesModule.view(service: viewModel.categoriesService)

        super.init()

        let holder = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        holder.addSubview(loadingSpinner)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: holder)

        title = "market.title".localized
        tabBarItem = UITabBarItem(title: "market.tab_bar_item".localized, image: UIImage(named: "market_2_24"), tag: 0)

        let marketTop100 = MarketTop100Module.view(service: MarketTop100Service())

        let marketFavorites = MarketFavoritesModule.view(service: MarketFavoritesService())
        subscribe(disposeBag, marketFavorites.isLoadingDriver) { [weak self] in self?.sync(index: 1, loading: $0) }

        viewControllers = [
            marketTop100,
            marketFavorites
        ]
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

    private func sync(index: Int, loading: Bool) {
        // todo: when change controller with loading to other, we need set new loading state
        loadingSpinner.isHidden = !loading
        if loading {
            loadingSpinner.startAnimating()
        } else {
            loadingSpinner.stopAnimating()
        }
    }

}
