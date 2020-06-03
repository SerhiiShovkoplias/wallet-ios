//  RestoreWalletViewController.swift

/*
	Package MobileWallet
	Created by S.Shovkoplyas on 27.05.2020
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

class RestoreWalletViewController: UIViewController {
    private let tableView = UITableView()
    private let items: [AppTableViewCellItem] = [
        AppTableViewCellItem(title: RestoreCellTitle.iCloudRestore.localized()),
        AppTableViewCellItem(title: RestoreCellTitle.phraseRestore.localized())]

    private enum RestoreCellTitle: String {
        case iCloudRestore = "Restore with iCloud"
        case phraseRestore = "Restore with recovery phrase"

        public func localized(args: CVarArg...) -> String {
            let localizedString = NSLocalizedString(self.rawValue, comment: "")
            return withVaList(args, { (args) -> String in
                return NSString(format: localizedString, locale: Locale.current, arguments: args) as String
            })
        }
    }

    private let navigationBar = NavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

extension RestoreWalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AppTableViewCell.self), for: indexPath) as! AppTableViewCell
        let item = items[indexPath.row]
        cell.configure(item)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        63
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: Setup subviews
extension RestoreWalletViewController {
    private func setupView() {
        view.backgroundColor = Theme.shared.colors.restoreWalletBackground
        navigationBar.backgroundColor = Theme.shared.colors.restoreWalletBackground
        setupNavigationBar()
        setupTableView()
    }

    private func setupNavigationBar() {
        navigationBar.title = NSLocalizedString("Restore Your Wallet", comment: "RestoreWalletViewController title")

        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        navigationBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func setupTableView() {
        tableView.register(AppTableViewCell.self, forCellReuseIdentifier: String(describing: AppTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorColor = Theme.shared.colors.restoreWalletBackground

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 25).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 128).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}
