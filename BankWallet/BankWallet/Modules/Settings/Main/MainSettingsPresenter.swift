import Foundation

class MainSettingsPresenter {
    private let router: IMainSettingsRouter
    private let interactor: IMainSettingsInteractor

    weak var view: IMainSettingsView?

    init(router: IMainSettingsRouter, interactor: IMainSettingsInteractor) {
        self.router = router
        self.interactor = interactor
    }

}

extension MainSettingsPresenter: IMainSettingsViewDelegate {

    func viewDidLoad() {
        view?.set(backedUp: interactor.nonBackedUpCount == 0)
        view?.set(baseCurrency: interactor.baseCurrency)
        view?.set(language: interactor.currentLanguage)
        view?.set(lightMode: interactor.lightMode)
        view?.set(appVersion: interactor.appVersion)

        view?.setTabItemBadge(count: interactor.nonBackedUpCount)
    }

    func didTapSecurity() {
        router.showSecuritySettings()
    }

    func didTapBaseCurrency() {
        router.showBaseCurrencySettings()
    }

    func didTapLanguage() {
        router.showLanguageSettings()
    }

    func didSwitch(lightMode: Bool) {
        interactor.set(lightMode: lightMode)
    }

    func didTapAbout() {
        router.showAbout()
    }

    func didTapTellFriends() {
        router.showShare(text: "settings_tell_friends.text".localized + "\n" + interactor.appWebPageLink)
    }

    func didTapAppLink() {
        router.openAppLink()
    }

}

extension MainSettingsPresenter: IMainSettingsInteractorDelegate {

    func didUpdateNonBackedUp(count: Int) {
        view?.set(backedUp: count == 0)
        view?.setTabItemBadge(count: count)
    }

    func didUpdateBaseCurrency() {
        view?.set(baseCurrency: interactor.baseCurrency)
    }

    func didUpdateLightMode() {
        router.reloadAppInterface()
    }

}
