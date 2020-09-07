//  BridgesConfigurationViewController.swift

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

class BridgesConfigurationViewController: SettingsParentTableViewController {

    typealias BridgesType = OnionSettings.BridgesType

    private lazy var bridgesConfiguration: BridgesConfuguration = {
        BridgesConfuguration(bridges: OnionSettings.currentlyUsedBridges, customBridges: OnionSettings.customBridges)
    }()

    private enum Section: Int {
        case chooseBridge = 1
    }

    private enum BridgesConfigurationItemTitle: CaseIterable {
        case requestBridgesFromTorproject
        case noBridges
        case obfs4
        case meekazure
        case custom

        var rawValue: String {
            switch self {
            case .requestBridgesFromTorproject: return NSLocalizedString("bridges_configuration.item.request_bridges_from_torproject", comment: "BridgesConfiguration view")

            case .noBridges: return NSLocalizedString("bridges_configuration.item.noBridges", comment: "BridgesConfiguration view")
            case .obfs4: return NSLocalizedString("bridges_configuration.item.obfs4", comment: "BridgesConfiguration view")
            case .meekazure: return NSLocalizedString("bridges_configuration.item.meekazure", comment: "BridgesConfiguration view")
            case .custom: return NSLocalizedString("bridges_configuration.item.custom", comment: "BridgesConfiguration view")
            }
        }
    }

    private let bridgesDescription: String = {
        let description = [
            NSLocalizedString("bridges_configuration.description.bridges", comment: "BridgesConfiguration view"),
            "",
            NSLocalizedString("bridges_configuration.description.obfs4", comment: "BridgesConfiguration view"),
            NSLocalizedString("bridges_configuration.description.meekazure", comment: "BridgesConfiguration view"),
            "",
            NSLocalizedString("bridges_configuration.description.custom", comment: "BridgesConfiguration view")
            ]
        return description.joined(separator: "\n")
    }()

    private lazy var chooseBridgeSectionItems: [SystemMenuTableViewCellItem] = {
        getBridgeSectionItems()
    }()

    private func getBridgeSectionItems() -> [SystemMenuTableViewCellItem] {
        [
            SystemMenuTableViewCellItem(title: BridgesConfigurationItemTitle.noBridges.rawValue, mark: OnionConnector.shared.bridgesConfiguration.bridges == BridgesType.none ? .scheduled : .none, hasArrow: false),
            SystemMenuTableViewCellItem(title: BridgesConfigurationItemTitle.obfs4.rawValue, mark: OnionConnector.shared.bridgesConfiguration.bridges == BridgesType.obfs4 ? .scheduled : .none, hasArrow: false),
            SystemMenuTableViewCellItem(title: BridgesConfigurationItemTitle.meekazure.rawValue, mark: OnionConnector.shared.bridgesConfiguration.bridges == BridgesType.meekazure ? .scheduled : .none, hasArrow: false),
            SystemMenuTableViewCellItem(title: BridgesConfigurationItemTitle.custom.rawValue, mark: OnionConnector.shared.bridgesConfiguration.bridges == BridgesType.custom ? .scheduled : .none)
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        chooseBridgeSectionItems = getBridgeSectionItems()
        tableView.reloadData()
    }
}

// MARK: Setup subviews
extension BridgesConfigurationViewController {
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigationBar.title = NSLocalizedString("bridges_configuration.title", comment: "BridgesConfiguration view")
        navigationBar.rightButton.isEnabled = false
        navigationBar.rightButtonAction = { [weak self] in
            guard let self = self else { return }
            OnionConnector.shared.addObserver(self)
            self.navigationBar.setProgress(0.0)
            self.navigationBar.progressView.isHidden = false
            self.navigationBar.rightButton.isEnabled = false
            self.view.isUserInteractionEnabled = false
            OnionConnector.shared.bridgesConfiguration = self.bridgesConfiguration
        }

        let title = NSLocalizedString("bridges_configuration.connect", comment: "BridgesConfiguration view")
        navigationBar.rightButton.setTitle(title, for: .normal)
        navigationBar.rightButton.setTitleColor(Theme.shared.colors.navigationBarPurple, for: .normal)
        navigationBar.rightButton.setTitleColor(Theme.shared.colors.navigationBarPurple?.withAlphaComponent(0.5), for: .highlighted)
        navigationBar.rightButton.setTitleColor(Theme.shared.colors.navigationBarPurple?.withAlphaComponent(0.25), for: .disabled)
        navigationBar.rightButton.titleLabel?.font = Theme.shared.fonts.settingsDoneButton
    }
}

extension BridgesConfigurationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .chooseBridge:
            return chooseBridgeSectionItems.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SystemMenuTableViewCell.self), for: indexPath) as! SystemMenuTableViewCell
        guard let section = Section(rawValue: indexPath.section) else { return cell }

        switch section {
        case .chooseBridge: cell.configure(chooseBridgeSectionItems[indexPath.row])
        }

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        65
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section), section == .chooseBridge  else { return nil }

        let footer = UIView()
        footer.backgroundColor = .clear

        let bridgesDescriptionLabel =  UILabel()
        bridgesDescriptionLabel.font = Theme.shared.fonts.settingsTableViewLastBackupDate
        bridgesDescriptionLabel.textColor =  Theme.shared.colors.settingsTableViewLastBackupDate

        bridgesDescriptionLabel.text = bridgesDescription
        bridgesDescriptionLabel.numberOfLines = 0
        footer.addSubview(bridgesDescriptionLabel)

        bridgesDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        bridgesDescriptionLabel.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 25).isActive = true
        bridgesDescriptionLabel.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -25).isActive = true
        bridgesDescriptionLabel.topAnchor.constraint(equalTo: footer.topAnchor, constant: 8).isActive = true
        bridgesDescriptionLabel.lineBreakMode = .byTruncatingMiddle

        return footer
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .chooseBridge:
            let raw = BridgesConfigurationItemTitle.allCases[indexPath.section + indexPath.row]

            switch raw {
            case .noBridges:
                bridgesConfiguration.bridges = BridgesType.none
            case .obfs4:
                bridgesConfiguration.bridges = BridgesType.obfs4
            case .meekazure:
                bridgesConfiguration.bridges = BridgesType.meekazure
            case .custom:
                navigationController?.pushViewController(CustomBridgesViewController(bridgesConfiguration: bridgesConfiguration), animated: true)
                return
            default:
                return
            }
            bridgesConfiguration.customBridges = nil
            navigationBar.rightButton.isEnabled = OnionSettings.currentlyUsedBridges != bridgesConfiguration.bridges
            chooseBridgeSectionItems.forEach { (item) in
                item.mark = .none
            }
            chooseBridgeSectionItems[indexPath.row].mark = .scheduled
        }
    }
}
