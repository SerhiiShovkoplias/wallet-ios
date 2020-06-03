//  RecoveryPhraseView.swift

/*
	Package MobileWallet
	Created by S.Shovkoplyas on 01.06.2020
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

protocol RecoveryPhraseViewDelegate: class {
    func didSelectWord(_ word: String, phraseView: RecoveryPhraseView)
}

class RecoveryPhraseView: UIView {
    weak var delegate: RecoveryPhraseViewDelegate?

    private let stackView = UIStackView()
    private var subStackViews = [UIStackView]()
    private var buttons = [UIButton]()

    private var minimumHeight: CGFloat
    private var maxCountInRaw: Int
    private var horizontalSpacing: CGFloat
    private var verticalSpacing: CGFloat
    private var minimumInsets: UIEdgeInsets
    private var cornerRadius: CGFloat
    private var showBorder: Bool

    private let font = Theme.shared.fonts.settingsRecoveryPhraseWorld!
    private let textColor = Theme.shared.colors.settingsRecoveryPhraseWorldText!
    private let textBackgroundColor = UIColor.clear
    private let buttonBorderColor = Theme.shared.colors.settingsRecoveryPhraseWorldBorder!

    private var heightConstraint: NSLayoutConstraint?

    init(words: [String],
         width: CGFloat,
         minimumHeight: CGFloat = 27,
         maxCountInRaw: Int = 4,
         horizontalSpacing: CGFloat = 12,
         verticalSpacing: CGFloat = 14,
         minimumInsets: UIEdgeInsets = UIEdgeInsets(top: 6.0, left: 12.0, bottom: 6.0, right: 12),
         cornerRadius: CGFloat = 5.0,
         showBorder: Bool = true) {

        self.minimumHeight = minimumHeight
        self.maxCountInRaw = maxCountInRaw
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.minimumInsets = minimumInsets
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder

        super.init(frame: .zero)
        setup(words: words, width: width)
    }

    init(minimumHeight: CGFloat,
         maxCountInRaw: Int = 4,
         horizontalSpacing: CGFloat = 12,
         verticalSpacing: CGFloat = 14,
         minimumInsets: UIEdgeInsets = UIEdgeInsets(top: 6.0, left: 12.0, bottom: 6.0, right: 12),
         cornerRadius: CGFloat = 5.0,
         showBorder: Bool = true) {

        self.minimumHeight = minimumHeight
        self.maxCountInRaw = maxCountInRaw
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.minimumInsets = minimumInsets
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder

        super.init(frame: .zero)
        self.minimumHeight = minimumHeight
        setupStackView(horizontalStackViews: [UIStackView]())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonAction(_ sender: UIButton) {
        delegate?.didSelectWord(sender.titleLabel?.text ?? "", phraseView: self)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            sender.alpha = 0.0
        }
    }

    func addWords(_ words: [String]) {
        let newButtons = createButtons(words: words)

        newButtons.forEach { (button) in
            guard let lastStackView = findLastFreeSubStackView(for: button) else {
                let newStackView = horizontalStackView(with: [button], intrinsicWidth: bounds.width)
                subStackViews.append(newStackView)
                stackView.addArrangedSubview(newStackView)
                return
            }
            buttons.append(button)
            var existingButtons = lastStackView.subviews.filter({ $0 is UIButton })
            existingButtons.append(button)
            stackView.removeArrangedSubview(lastStackView)
            subStackViews.removeAll(where: { $0 == lastStackView })
            let newStack = horizontalStackView(with: existingButtons, intrinsicWidth: bounds.width)
            subStackViews.append(newStack)
            stackView.addArrangedSubview(newStack)
        }
        heightConstraint?.constant = heightForStackView()
    }

    private func findLastFreeSubStackView(for button: UIButton) -> UIStackView? {
        let lastSubStackView = subStackViews.last { (stackView) -> Bool in
            var buttonsCount = 0
            var width: CGFloat = 0
            stackView.subviews.forEach({
                if $0 is UIButton {
                    buttonsCount += 1
                    width += $0.bounds.width + stackView.spacing
                }
            })
            return buttonsCount < maxCountInRaw && bounds.width > (width + button.intrinsicContentSize.width)
        }
        return lastSubStackView
    }

    private func setup(words: [String], width: CGFloat) {
        buttons = createButtons(words: words)
        subStackViews = createSubStackViews(intrinsicWidth: width)
        setupStackView(horizontalStackViews: subStackViews)
    }

    private func createButtons(words: [String]) -> [UIButton] {
        var intrinsicButtons = [UIButton]()
        words.forEach({
            let button = UIButton()
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            button.setTitle($0, for: .normal)
            button.titleLabel?.font = font
            button.backgroundColor = textBackgroundColor
            button.setTitleColor(textColor, for: .normal)
            button.setTitleColor(textColor.withAlphaComponent(0.5), for: .highlighted)

            button.layer.cornerRadius = cornerRadius
            button.layer.borderColor = showBorder ? buttonBorderColor.cgColor : UIColor.clear.cgColor
            button.layer.borderWidth = 1.0
            button.layer.masksToBounds = true
            let widthConstraint =  button.widthAnchor.constraint(equalToConstant: (button.intrinsicContentSize.width + minimumInsets.left + minimumInsets.right))
            widthConstraint.isActive = true

            intrinsicButtons.append(button)
        })
        return intrinsicButtons
    }

    private func createSubStackViews(intrinsicWidth: CGFloat) -> [UIStackView] {
        var width: CGFloat = 0.0
        var stackViews = [UIStackView]()
        var currentStack = [UIView]()

        buttons.forEach({
            var labelWidth: CGFloat

            if $0.bounds.width > 0 {
                labelWidth = $0.bounds.width
            } else {
                labelWidth = $0.intrinsicContentSize.width + minimumInsets.left + minimumInsets.right
            }

            let newWidth = (width + labelWidth + CGFloat(currentStack.count - 1) * horizontalSpacing)

            if newWidth <= intrinsicWidth {
                currentStack.append($0)
            }

            if currentStack.count == maxCountInRaw {
                stackViews.append(horizontalStackView(with: currentStack, intrinsicWidth: intrinsicWidth))
                currentStack.removeAll()
                width = 0.0
                return
            }

            if newWidth > intrinsicWidth {
                stackViews.append(horizontalStackView(with: currentStack, intrinsicWidth: intrinsicWidth))
                currentStack.removeAll()
                currentStack.append($0)

                if $0 == buttons.last {
                    stackViews.append(horizontalStackView(with: currentStack, intrinsicWidth: intrinsicWidth))
                    currentStack.removeAll()
                }
                width = 0.0
            }

            width += labelWidth
        })

        return stackViews
    }

    private func horizontalStackView(with views: [UIView], intrinsicWidth: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = horizontalSpacing

        var width: CGFloat = 0.0

        views.forEach {
            guard let button = $0 as? UIButton else { return }
            let buttonWidth = button.bounds.width > 0 ? button.bounds.width : (button.titleLabel?.font.pointSize ?? 0.0) + minimumInsets.left + minimumInsets.right
            width += buttonWidth + horizontalSpacing

            stackView.addArrangedSubview(button)
        }

        if views.count < maxCountInRaw || width < intrinsicWidth {
            let stubView = UIView()
            stubView.backgroundColor = .clear
            let widthConstraint = stubView.widthAnchor.constraint(equalToConstant: intrinsicWidth - width)
            widthConstraint.isActive = true
            widthConstraint.priority = .defaultLow
            stackView.addArrangedSubview(stubView)
        }

        return stackView
    }

    private func setupStackView(horizontalStackViews: [UIStackView]) {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = verticalSpacing

        horizontalStackViews.forEach {
            stackView.addArrangedSubview($0)
        }

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        heightConstraint = stackView.heightAnchor.constraint(equalToConstant: heightForStackView())
        heightConstraint?.isActive = true
    }

    private func heightForStackView() -> CGFloat {
        var labelHeight: CGFloat

        if buttons.first?.bounds.height == 0 {
            labelHeight = (buttons.first?.titleLabel?.font.pointSize ?? 0.0) + minimumInsets.top + minimumInsets.bottom
        } else {
            labelHeight = buttons.first?.bounds.height ?? 0.0
        }

        let height: CGFloat = CGFloat(subStackViews.count) * labelHeight + CGFloat(subStackViews.count - 1) * stackView.spacing
        return height < minimumHeight ? minimumHeight : height
    }
}
