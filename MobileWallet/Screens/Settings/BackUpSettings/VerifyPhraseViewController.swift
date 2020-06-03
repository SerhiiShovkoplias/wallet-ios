//  VerifyPhraseViewController.swift

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

class VerifyPhraseViewController: SettingsParentViewController {
    private let continueButton = ActionButton()
    private let headerLabel = UILabel()
    private var selectablePhraseView: WordsFlexView!

    private let fillablePhraseContainer = UIView()
    private var fillablePhraseView: WordsFlexView!
    private let fillableContainerDescription = UILabel()
}

extension VerifyPhraseViewController {
    override func setupViews() {
        super.setupViews()
        setupHeaderLabel()
        setupVerificationView()
        setupPhraseView()
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
        headerLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20).isActive = true
    }

    private func setupVerificationView() {
        fillablePhraseContainer.backgroundColor = Theme.shared.colors.settingsVerificationPhraseView
        fillablePhraseContainer.layer.cornerRadius = 10.0
        fillablePhraseContainer.layer.masksToBounds = true

        view.addSubview(fillablePhraseContainer)

        fillablePhraseContainer.translatesAutoresizingMaskIntoConstraints = false
        fillablePhraseContainer.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20).isActive = true
        fillablePhraseContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        fillablePhraseContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        fillablePhraseContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 188).isActive = true

        fillablePhraseView = WordsFlexView(type: .fillable,
                                                       minimumHeight: 17.0,
                                                       maxCountInRaw: 5,
                                                       horizontalSpacing: 20.0,
                                                       verticalSpacing: 10,
                                                       minimumInsets: UIEdgeInsets(top: 3.0, left: 1.0, bottom: 3.0, right: 1.0),
                                                       showBorder: false)

        fillablePhraseView.delegate = self
        fillablePhraseContainer.addSubview(fillablePhraseView!)

        fillablePhraseView.translatesAutoresizingMaskIntoConstraints = false
        fillablePhraseView.topAnchor.constraint(equalTo: fillablePhraseContainer.topAnchor, constant: 20).isActive = true
        fillablePhraseView.leadingAnchor.constraint(equalTo: fillablePhraseContainer.leadingAnchor, constant: 20).isActive = true
        fillablePhraseView.trailingAnchor.constraint(equalTo: fillablePhraseContainer.trailingAnchor, constant: -20).isActive = true
        fillablePhraseView.bottomAnchor.constraint(lessThanOrEqualTo: fillablePhraseContainer.bottomAnchor, constant: -20).isActive = true

        fillableContainerDescription.text = NSLocalizedString("Tap on the words above in the correct order", comment: "Fillable phrase container description")
        fillableContainerDescription.font = Theme.shared.fonts.settingsFillablePhraseViewDescription
        fillableContainerDescription.textColor = Theme.shared.colors.settingsFillablePhraseViewDescription
        fillableContainerDescription.textAlignment = .center

        fillablePhraseContainer.addSubview(fillableContainerDescription)

        fillableContainerDescription.translatesAutoresizingMaskIntoConstraints = false
        fillableContainerDescription.centerYAnchor.constraint(equalTo: fillablePhraseContainer.centerYAnchor).isActive = true
        fillableContainerDescription.centerXAnchor.constraint(equalTo: fillablePhraseContainer.centerXAnchor).isActive = true
        fillableContainerDescription.leadingAnchor.constraint(greaterThanOrEqualTo: fillablePhraseContainer.leadingAnchor, constant: 20).isActive = true
        fillableContainerDescription.trailingAnchor.constraint(lessThanOrEqualTo: fillablePhraseContainer.trailingAnchor, constant: -20).isActive = true

    }

    private func setupPhraseView() {
        let words = ["Aurora", "Fluffy", "Tari", "Gems", "Digital", "Emojis", "Collect", "Animo", "Aurora", "Fluffy", "Tari", "Gems", "Digital", "Emojis", "Collect", "Animo", "Aurora", "Fluffy", "Tari", "Gems", "Digital", "Emojis", "Collect", "Animo"]

        selectablePhraseView = WordsFlexView(type: .selectable, words: words, width: (view.bounds.width - 50))
        selectablePhraseView?.delegate = self

        view.addSubview(selectablePhraseView)

        selectablePhraseView.translatesAutoresizingMaskIntoConstraints = false
        selectablePhraseView.topAnchor.constraint(equalTo: fillablePhraseContainer.bottomAnchor, constant: 25).isActive = true
        selectablePhraseView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        selectablePhraseView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
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

extension VerifyPhraseViewController: WordsFlexViewDelegate {
    func didSelectWord(word: String, intId: Int, phraseView: WordsFlexView) {
        switch phraseView.type {
        case .fillable: self.selectablePhraseView?.restore(word: word, intId: intId)

        case .selectable: fillablePhraseView?.addWord(word, intId: intId)
        }

        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.fillableContainerDescription.alpha = self.fillablePhraseView.words.isEmpty ? 1.0 : 0.0
        }
    }
}