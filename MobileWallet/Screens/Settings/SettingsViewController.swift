//  SettingsViewController.swift

/*
	Package MobileWallet
	Created by S.Shovkoplyas on 28.05.2020
	Using Swift 5.0
	Running on macOS 10.15

	Copyright 2019 The Tari Project

	Redistribution and use in source and binary forms, with or
	without modification, are permitted provided that the
	following conditions are met:

	1. Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.

	2. Redistributions in binary form must reproduce the above
	copyright notice, this list of conditions and the following disclaimer in the
	documentation and/or other materials provided with the distribution.

	3. Neither the name of the copyright holder nor the names of
	its contributors may be used to endorse or promote products
	derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
	CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
	HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit

class SettingsViewController: SettingsParentTableViewController {

    private enum Section: Int {
        case security
        case more
    }

    private enum SettingsItemTitle: String {
        case securityHeader = "Security"
        case backUpWallet = "Back Up Wallet"

        case moreHeader = "More"
        case visitTari = "Visit Tari.com"
        case contributeToTariAurora = "Contribute to Tari Aurora"
        case userAgreement = "User Agreement"
        case privacyPolicy = "Privacy Policy"
        case disclaimer = "Disclaimer"

        public func localized(args: CVarArg...) -> String {
            let localizedString = NSLocalizedString(self.rawValue, comment: "")
            return withVaList(args, { (args) -> String in
                return NSString(format: localizedString, locale: Locale.current, arguments: args) as String
            })
        }
    }

    private let headers: [SettingsItemTitle] = [.securityHeader, .moreHeader]
    private let securitySectionItems: [AppTableViewCellItem] = [AppTableViewCellItem(title: SettingsItemTitle.backUpWallet.localized(), mark: .attention)]

    private let moreSectionItems: [AppTableViewCellItem] = [
        AppTableViewCellItem(title: SettingsItemTitle.visitTari.localized()),
        AppTableViewCellItem(title: SettingsItemTitle.contributeToTariAurora.localized()),
        AppTableViewCellItem(title: SettingsItemTitle.userAgreement.localized()),
        AppTableViewCellItem(title: SettingsItemTitle.privacyPolicy.localized()),
        AppTableViewCellItem(title: SettingsItemTitle.disclaimer.localized())]

    private let links: [SettingsItemTitle: URL?] = [
        .visitTari: URL(string: TariSettings.shared.tariUrl),
        .contributeToTariAurora: URL(string: TariSettings.shared.contributeUrl),
        .userAgreement: URL(string: TariSettings.shared.userAgreementUrl),
        .privacyPolicy: URL(string: TariSettings.shared.privacyPolicyUrl),
        .disclaimer: URL(string: TariSettings.shared.disclaimer)]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func onBackUpWalletAction() {
        navigationController?.pushViewController(BackUpWalletSettings(), animated: true)
    }

    private func onLinkAction(indexPath: IndexPath) {
        let item = moreSectionItems[indexPath.row]
        guard
            let itemTitle = SettingsItemTitle(rawValue: item.title),
            let url = links[itemTitle]
        else { return }

        UserFeedback.shared.openWebBrowser(url: url!)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .security: return securitySectionItems.count
        case .more: return moreSectionItems.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AppTableViewCell.self), for: indexPath) as! AppTableViewCell

        guard let section = Section(rawValue: indexPath.section) else { return cell }
        switch section {
        case .security: cell.configure(securitySectionItems[indexPath.row])
        case .more: cell.configure(moreSectionItems[indexPath.row])
        }

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        header.heightAnchor.constraint(equalToConstant: 70).isActive = true

        let label = UILabel()
        label.font = Theme.shared.fonts.settingsTableViewHeader
        label.text = headers[section].rawValue

        header.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 25).isActive = true
        label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -15).isActive = true

        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .security: onBackUpWalletAction()
        case .more: onLinkAction(indexPath: indexPath)
        }
    }
}

// MARK: Setup subviews
extension SettingsViewController {
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigationBar.backButton.isHidden = true
        navigationBar.rightButtonAction = { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }

        let title = NSLocalizedString("Done", comment: "SettingsViewController Done button")
        navigationBar.rightButton.setTitle(title, for: .normal)
        navigationBar.rightButton.setTitleColor(Theme.shared.colors.settingsDoneButtonTitle, for: .normal)
        navigationBar.rightButton.titleLabel?.font = Theme.shared.fonts.settingsDoneButton
    }
}