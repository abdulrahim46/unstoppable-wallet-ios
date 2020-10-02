import ThemeKit
import RxSwift
import RxCocoa

class WalletConnectInitialConnectViewController: ThemeViewController {
    private let baseView: WalletConnectView
    private let viewModel: WalletConnectInitialConnectViewModel

    private let peerMetaLabel = UILabel()
    private let connectingLabel = UILabel()
    private let approveButton = ThemeButton()
    private let rejectButton = ThemeButton()

    private let disposeBag = DisposeBag()

    init?(baseView: WalletConnectView, viewModel: WalletConnectInitialConnectViewModel) {
        self.baseView = baseView
        self.viewModel = viewModel

        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Wallet Connect"

        view.addSubview(peerMetaLabel)
        peerMetaLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(CGFloat.margin6x)
            maker.top.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.margin6x)
        }

        peerMetaLabel.textColor = .themeRemus

        view.addSubview(connectingLabel)
        connectingLabel.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(CGFloat.margin6x)
            maker.top.equalTo(view.safeAreaLayoutGuide).inset(CGFloat.margin6x)
        }

        connectingLabel.text = "Connecting..."
        connectingLabel.textColor = .themeGray

        view.addSubview(approveButton)
        approveButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(CGFloat.margin6x)
            maker.height.equalTo(CGFloat.heightButton)
        }

        approveButton.apply(style: .primaryYellow)
        approveButton.setTitle("Approve", for: .normal)
        approveButton.addTarget(self, action: #selector(onTapApprove), for: .touchUpInside)

        view.addSubview(rejectButton)
        rejectButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(CGFloat.margin6x)
            maker.top.equalTo(approveButton.snp.bottom).offset(CGFloat.margin4x)
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(CGFloat.margin6x)
            maker.height.equalTo(CGFloat.heightButton)
        }

        rejectButton.apply(style: .primaryGray)
        rejectButton.setTitle("Reject", for: .normal)
        rejectButton.addTarget(self, action: #selector(onTapReject), for: .touchUpInside)

        viewModel.connectingDriver
                .drive(onNext: { [weak self] connecting in
                    self?.connectingLabel.isHidden = !connecting
                })
                .disposed(by: disposeBag)

        viewModel.peerMetaDriver
                .drive(onNext: { [weak self] peerMeta in
                    if let peerMeta = peerMeta {
                        self?.peerMetaLabel.isHidden = false
                        self?.peerMetaLabel.text = peerMeta.name
                        self?.approveButton.isEnabled = true
                        self?.rejectButton.isEnabled = true
                    } else {
                        self?.peerMetaLabel.isHidden = true
                        self?.approveButton.isEnabled = false
                        self?.rejectButton.isEnabled = false
                    }
                })
                .disposed(by: disposeBag)

        viewModel.approvedSignal
                .emit(onNext: { [weak self] peerMeta in
                    self?.baseView.viewModel.onApproveSession(peerMeta: peerMeta)
                })
                .disposed(by: disposeBag)

        viewModel.rejectedSignal
                .emit(onNext: { [weak self] in
                    self?.baseView.viewModel.onRejectSession()
                })
                .disposed(by: disposeBag)
    }

    @objc private func onTapApprove() {
        viewModel.approve()
    }

    @objc private func onTapReject() {
        viewModel.reject()
    }

}