//  ConfirmPhraseViewController.swift

/*
	Package MobileWallet
	Created by S.Shovkoplyas on 02.06.2020
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

class ConfirmPhraseViewController: SettingsParentViewController {
    private let continueButton = ActionButton()
    private let headerLabel = UILabel()
    private var phraseView: RecoveryPhraseView?
    private var confirmRecoveryPhraseView: RecoveryPhraseView?
}

extension ConfirmPhraseViewController {
    override func setupViews() {
        super.setupViews()
        setupHeaderLabel()
        setupPhraseView()
        setupVerificationView()
        setupContinueButton()
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigationBar.title = NSLocalizedString("Verify Seed Phrase", comment: "ConfirmPhraseViewController title")
    }

    private func setupHeaderLabel() {
        headerLabel.font = Theme.shared.fonts.settingsBackupWalletDescription
        headerLabel.textColor = Theme.shared.colors.settingsBackupWalletDescription
        headerLabel.text = NSLocalizedString("Select the words in the correct order.", comment: "ConfirmPhraseViewController header title")

        view.addSubview(headerLabel)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        headerLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 35).isActive = true
    }

    private func setupPhraseView() {
        let words = ["Aurora", "Fluffy", "Tari", "Gems", "Digital", "Emojis", "Collect", "Animo", "Aurora", "Fluffy", "Tari", "Gems", "Digital", "Emojis", "Collect", "Animo", "Aurora", "Fluffy", "Tari", "Gems", "Digital", "Emojis", "Collect", "Animo", "Aurora", "Fluffy", "Tari", "Gems", "Digital", "Emojis", "Collect", "Animo"]

        phraseView = RecoveryPhraseView(words: words, width: (view.bounds.width - 50))
        phraseView?.delegate = self

        view.addSubview(phraseView!)

        phraseView!.translatesAutoresizingMaskIntoConstraints = false
        phraseView!.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 25).isActive = true
        phraseView!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        phraseView!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
    }

    private func setupVerificationView() {
        let phraseContainer = UIView()
        phraseContainer.backgroundColor = Theme.shared.colors.settingsVerificationPhraseView
        phraseContainer.layer.cornerRadius = 10.0
        phraseContainer.layer.masksToBounds = true

        view.addSubview(phraseContainer)

        phraseContainer.translatesAutoresizingMaskIntoConstraints = false
        phraseContainer.topAnchor.constraint(equalTo: phraseView!.bottomAnchor, constant: 25).isActive = true
        phraseContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        phraseContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        phraseContainer.heightAnchor.constraint(equalToConstant: 188).isActive = true

        confirmRecoveryPhraseView = RecoveryPhraseView(minimumHeight: 15.0,
                                                       maxCountInRaw: 5,
                                                       horizontalSpacing: 20.0,
                                                       verticalSpacing: 10,
                                                       minimumInsets: .zero,
                                                       showBorder: false)

        confirmRecoveryPhraseView?.delegate = self
        phraseContainer.addSubview(confirmRecoveryPhraseView!)

        confirmRecoveryPhraseView!.translatesAutoresizingMaskIntoConstraints = false
        confirmRecoveryPhraseView!.topAnchor.constraint(equalTo: phraseContainer.topAnchor, constant: 20).isActive = true
        confirmRecoveryPhraseView!.leadingAnchor.constraint(equalTo: phraseContainer.leadingAnchor, constant: 20).isActive = true
        confirmRecoveryPhraseView!.trailingAnchor.constraint(equalTo: phraseContainer.trailingAnchor, constant: -20).isActive = true
    }

    private func setupContinueButton() {
        continueButton.setTitle(NSLocalizedString("Complete Verification", comment: "Recovery phrase continue button"), for: .normal)
        continueButton.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false

        continueButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                constant: Theme.shared.sizes.appSidePadding).isActive = true
        continueButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -Theme.shared.sizes.appSidePadding).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor,
                                                constant: 0).isActive = true

        let continueButtonConstraint = continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        continueButtonConstraint.priority = UILayoutPriority(rawValue: 999)
        continueButtonConstraint.isActive = true

        let continueButtonSecondConstraint = continueButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        continueButtonSecondConstraint.priority = UILayoutPriority(rawValue: 1000)
        continueButtonSecondConstraint.isActive = true
    }

    @objc private func continueButtonAction() {

    }
}

extension ConfirmPhraseViewController: RecoveryPhraseViewDelegate {
    func didSelectWord(_ word: String, phraseView: RecoveryPhraseView) {
        confirmRecoveryPhraseView?.addWords([word])
    }
}
