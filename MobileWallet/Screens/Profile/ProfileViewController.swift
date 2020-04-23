//  ProfileViewController.swift

/*
	Package MobileWallet
	Created by Gabriel Lupu on 04/02/2020
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

class ProfileViewController: UIViewController {

    var closeButton = UIButton()
    var titleLabel = UILabel()
    var emojiView = EmoticonView()
    var copyEmojiButton = TextButton()
    var separatorView = UIView()
    var middleLabel = UILabel()
    var bottomView = UIView()
    var qrContainer = UIView()
    var qrImageView = UIImageView()

    private var emojis: String?

    // MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCloseButton()
        setupTitleLabel()
        setupEmojiView()
        setupCopyEmojiButton()
        setupSeparatorView()
        setupMiddleLabel()
        setupBottomView()
        setupQRContainer()
        setupQRImageView()
        generateQRCode()
        customizeViews()

        Tracker.shared.track("/home/profile", "Profile - Wallet Info")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addShadowToQRView()
    }

    // MARK: - Private functions

    private func setupCloseButton() {
        closeButton.setImage(Theme.shared.images.close!, for: .normal)
        closeButton.addTarget(self, action: #selector(onDismissAction), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        closeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 25).isActive = true
    }

    private func setupTitleLabel() {
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Theme.shared.sizes.appSidePadding).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Theme.shared.sizes.appSidePadding).isActive = true
        titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 33).isActive = true
    }

    private func setupEmojiView() {
        view.addSubview(emojiView)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        emojiView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        emojiView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30).isActive = true
    }

    private func setupCopyEmojiButton() {
        copyEmojiButton.addTarget(self, action: #selector(onCopyEmojiAction), for: .touchUpInside)
        view.addSubview(copyEmojiButton)
        copyEmojiButton.translatesAutoresizingMaskIntoConstraints = false
        copyEmojiButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        copyEmojiButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
        copyEmojiButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20).isActive = true
        copyEmojiButton.topAnchor.constraint(equalTo: emojiView.bottomAnchor, constant: 20).isActive = true
        copyEmojiButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    private func setupSeparatorView() {
        separatorView.backgroundColor = .white //TODO theme color
        view.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Theme.shared.sizes.appSidePadding).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Theme.shared.sizes.appSidePadding).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.topAnchor.constraint(lessThanOrEqualTo: copyEmojiButton.bottomAnchor, constant: 23).isActive = true
    }

    private func setupMiddleLabel() {
        middleLabel.numberOfLines = 0
        middleLabel.textAlignment = .center
        view.addSubview(middleLabel)
        middleLabel.translatesAutoresizingMaskIntoConstraints = false
        middleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Theme.shared.sizes.appSidePadding).isActive = true
        middleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Theme.shared.sizes.appSidePadding).isActive = true
        middleLabel.topAnchor.constraint(lessThanOrEqualTo: separatorView.bottomAnchor, constant: 23).isActive = true
    }

    private func setupBottomView() {
        bottomView.backgroundColor = Theme.shared.colors.profileBackground!
        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        bottomView.topAnchor.constraint(lessThanOrEqualTo: middleLabel.bottomAnchor, constant: 23).isActive = true
    }

    private func setupQRContainer() {
        qrContainer.backgroundColor = Theme.shared.colors.appBackground
        bottomView.addSubview(qrContainer)
        qrContainer.translatesAutoresizingMaskIntoConstraints = false
        qrContainer.leadingAnchor.constraint(greaterThanOrEqualTo: bottomView.leadingAnchor, constant: 50).isActive = true
        qrContainer.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor, constant: 0).isActive = true
        qrContainer.trailingAnchor.constraint(greaterThanOrEqualTo: bottomView.trailingAnchor, constant: -50).isActive = true
        qrContainer.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20).isActive = true
        bottomView.bottomAnchor.constraint(greaterThanOrEqualTo: qrContainer.bottomAnchor, constant: 20).isActive = true
        qrContainer.heightAnchor.constraint(equalTo: qrContainer.widthAnchor, multiplier: 1).isActive = true
    }

    private func setupQRImageView() {
        qrContainer.addSubview(qrImageView)
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.leadingAnchor.constraint(equalTo: qrContainer.leadingAnchor, constant: 20).isActive = true
        qrImageView.trailingAnchor.constraint(equalTo: qrContainer.trailingAnchor, constant: -20).isActive = true
        qrImageView.bottomAnchor.constraint(equalTo: qrContainer.bottomAnchor, constant: -20).isActive = true
        qrImageView.topAnchor.constraint(equalTo: qrContainer.topAnchor, constant: 20).isActive = true
    }

    private func customizeTitleLabel() {
        let shareYourEmojiString = NSLocalizedString("Your Emoji ID is your wallet address. Share it with others to receive Tari.", comment: "Profile title label")
        let toMakeBold = NSLocalizedString("Emoji ID", comment: "Profile title label")

        let attributedString = NSMutableAttributedString(
            string: shareYourEmojiString,
            attributes: [
                .font: Theme.shared.fonts.profileTitleLightLabel!,
                .foregroundColor: Theme.shared.colors.profileTitleTextColor!,
                .kern: -0.33
        ])

        if let startIndex = shareYourEmojiString.indexDistance(of: toMakeBold) {
            attributedString.addAttribute(.font, value: Theme.shared.fonts.profileTitleRegularLabel!, range: NSRange(location: startIndex, length: toMakeBold.count))
        }

        titleLabel.attributedText = attributedString
    }

    private func setEmojiID() {
        if let pubKey = TariLib.shared.tariWallet?.publicKey.0 {
            let (emojis, _) = pubKey.emojis

            self.emojis = emojis

            emojiView.setUpView(emojiText: emojis, type: .buttonView, textCentered: true, inViewController: self, showContainerViewBlur: false)
        }
    }

    private func customizeCopyMyEmojiButton() {
        copyEmojiButton.setVariation(.secondary)
        let titleButton = NSLocalizedString("Copy my emoji ID", comment: "Profile title button")
        self.copyEmojiButton.setTitle(titleButton, for: .normal)
    }

    private func customizeSeparatorView() {
        separatorView.backgroundColor = Theme.shared.colors.profileSeparatorView!
    }

    private func customizeMiddleLabel() {
        let middleLabelText = NSLocalizedString("Transacting in person? Others can scan this QR code from the Tari Aurora App to send you Tari.", comment: "Profile middle label")

        self.middleLabel.text = middleLabelText
        self.middleLabel.font = Theme.shared.fonts.profileMiddleLabel
        self.middleLabel.textColor = Theme.shared.colors.profileMiddleLabel!
    }

    private func genQRCode() throws {
        guard let wallet = TariLib.shared.tariWallet else {
            throw WalletErrors.walletNotInitialized
        }

        let (walletPublicKey, walletPublicKeyError) = wallet.publicKey
        guard let pubKey = walletPublicKey else {
            throw walletPublicKeyError!
        }

        let (deeplink, deeplinkError) = pubKey.hexDeeplink
        guard deeplinkError == nil else {
            throw deeplinkError!
        }

        let deepLinkData = deeplink.data(using: .utf8)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(deepLinkData, forKey: "inputMessage")
        filter?.setValue("L", forKey: "inputCorrectionLevel")

        if let output = filter?.outputImage {
            let scaleX = UIScreen.main.bounds.width / output.extent.size.width
            let scaleY = UIScreen.main.bounds.width / output.extent.size.height
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            let scaledOutput = output.transformed(by: transform)
            qrImageView.image = UIImage(ciImage: scaledOutput)
        }
    }

    private func customizeViews() {
        view.backgroundColor = Theme.shared.colors.profileBackground!
        customizeTitleLabel()
        setEmojiID()
        customizeCopyMyEmojiButton()
        customizeSeparatorView()
        customizeMiddleLabel()
    }

    private func generateQRCode() {
        do {
            try genQRCode()
        } catch {
            UserFeedback.shared.error(
                title: NSLocalizedString("Failed to generate QR", comment: "Profile view"),
                description: "",
                error: error)
        }
    }

    private func copyToClipboard() throws {
        guard let wallet = TariLib.shared.tariWallet else {
            throw WalletErrors.walletNotInitialized
        }

        let (walletPublicKey, walletPublicKeyError) = wallet.publicKey
        guard let pubKey = walletPublicKey else {
            throw walletPublicKeyError!
        }

        let (emojis, emojisError) = pubKey.emojis
        guard emojisError == nil else {
            throw emojisError!
        }

        let pasteboard = UIPasteboard.general
        pasteboard.string = emojis
    }

    private func addShadowToQRView() {
        qrContainer.layer.shadowOpacity = 0.5
        qrContainer.layer.shadowOffset = CGSize(width: 20, height: 20)
        qrContainer.layer.shadowRadius = 3.0
        qrContainer.layer.shadowColor = Theme.shared.colors.profileQRShadow?.cgColor

        let shadowRect: CGRect = qrContainer.bounds.insetBy(dx: 4, dy: 4)
        qrContainer.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
        qrContainer.layer.shouldRasterize = true
        qrContainer.layer.rasterizationScale = UIScreen.main.scale
        qrContainer.layer.masksToBounds = false
    }

    // MARK: - Actions
    @objc func onDismissAction() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func onCopyEmojiAction() {
        do {
            try copyToClipboard()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } catch {
            UserFeedback.shared.error(
                title: NSLocalizedString("Failed to copy to clipboard", comment: "Profile view"),
                description: "",
                error: error
            )
        }

        let titleButton = NSLocalizedString("Copied!", comment: "Profile copied button")
        self.copyEmojiButton.setTitle(titleButton, for: .normal)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            let titleButton = NSLocalizedString("Copy my emoji ID", comment: "Profile title button")
            self.copyEmojiButton.setTitle(titleButton, for: .normal)
        }
    }
}
