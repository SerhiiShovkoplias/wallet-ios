//  AdvancedSettingsViewController.swift

/*
	Package MobileWallet
	Created by S.Shovkoplyas on 01.09.2020
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

class AdvancedSettingsViewController: SettingsParentTableViewController {
    private enum Section: Int {
        case baseNode
        case torNode
    }

    private enum AdvancedSettingsItemTitle: CaseIterable {
        case baseNodeAddressAndPublicKey
        case bridgeConfiguration

        var rawValue: String {
            switch self {
            case .baseNodeAddressAndPublicKey: return NSLocalizedString("advanced_settings.item.base_node_adress_and_public_key", comment: "AdvancedSettings view")
            case .bridgeConfiguration: return NSLocalizedString("advanced_settings.item.bridge_configuration", comment: "AdvancedSettings view")
            }
        }
    }

    private enum AdvancedSettingsHeaderTitle: CaseIterable {
        case baseNodeHeader
        case torNodeHeader

        var rawValue: String {
            switch self {
            case .baseNodeHeader: return NSLocalizedString("advanced_settings.item.header.baseNode", comment: "AdvancedSettings view")
            case .torNodeHeader: return NSLocalizedString("advanced_settings.item.header.torNode", comment: "AdvancedSettings view")
            }
        }
    }

    private lazy var baseNodeSectionItems: [SystemMenuTableViewCellItem] = [
        SystemMenuTableViewCellItem(title: AdvancedSettingsItemTitle.baseNodeAddressAndPublicKey.rawValue) ]

    private let torNodeSectionItems: [SystemMenuTableViewCellItem] = [
        SystemMenuTableViewCellItem(title: AdvancedSettingsItemTitle.bridgeConfiguration.rawValue)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: Setup subviews
extension AdvancedSettingsViewController {
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigationBar.title = NSLocalizedString("advanced_settings.title", comment: "AdvancedSettings view")
        navigationBar.backButton.isHidden = true
        navigationBar.rightButtonAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        let title = NSLocalizedString("settings.done", comment: "Settings view")
        navigationBar.rightButton.setTitle(title, for: .normal)
        navigationBar.rightButton.setTitleColor(Theme.shared.colors.settingsDoneButtonTitle, for: .normal)
        navigationBar.rightButton.titleLabel?.font = Theme.shared.fonts.settingsDoneButton
    }
}

extension AdvancedSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .baseNode: return baseNodeSectionItems.count
        case .torNode: return torNodeSectionItems.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SystemMenuTableViewCell.self), for: indexPath) as! SystemMenuTableViewCell
        guard let section = Section(rawValue: indexPath.section) else { return cell }

        switch section {
        case .baseNode: cell.configure(baseNodeSectionItems[indexPath.row])
        case .torNode: cell.configure(torNodeSectionItems[indexPath.row])
        }

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        header.heightAnchor.constraint(equalToConstant: 70).isActive = true

        let label = UILabel()
        label.font = Theme.shared.fonts.settingsViewHeader
        label.text = AdvancedSettingsHeaderTitle.allCases[section].rawValue

        header.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 25).isActive = true
        label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -15).isActive = true

        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .baseNode:
            if AdvancedSettingsItemTitle.allCases[indexPath.row + indexPath.section] == .baseNodeAddressAndPublicKey {
                onBaseNodeAddressAndPublicKeyAction()
            }
        case .torNode:
            if AdvancedSettingsItemTitle.allCases[indexPath.row + indexPath.section] == .bridgeConfiguration {
                onBridgeConfigurationAction()
            }
        }
    }

    private func onBaseNodeAddressAndPublicKeyAction() {

    }

    private func onBridgeConfigurationAction() {
        let bridgesConfigurationViewController = BridgesConfigurationViewController()
        navigationController?.pushViewController(bridgesConfigurationViewController, animated: true)
    }
}
