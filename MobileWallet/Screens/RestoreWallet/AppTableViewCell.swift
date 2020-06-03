//  AppTableViewCell.swift

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

struct AppTableViewCellItem {
    let title: String
    var mark: AppTableViewCell.AppTableViewCellMark = .none
}

class AppTableViewCell: UITableViewCell {

    enum AppTableViewCellMark: Equatable {
        case none
        case attention
        case success
    }

    private let arrow = UIImageView()
    private let markImageView = UIImageView()
    private let titleLabel = UILabel()

    var mark: AppTableViewCellMark = .none {
        didSet {
            switch mark {
            case .none: markImageView.image = nil
            case .attention: markImageView.image = Theme.shared.images.attention!
            case .success: markImageView.image = Theme.shared.images.success!
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // should be overridden with empty body for fix blinking
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.contentView.alpha = 0.5
        } else {
            UIView.animate(withDuration: CATransaction.animationDuration(), delay: 0, options: .curveEaseIn, animations: {
                self.contentView.alpha = 1
            })
        }
    }

    func configure(_ item: AppTableViewCellItem) {
        titleLabel.text = item.title
        mark = item.mark
    }
}

// MARK: Setup views
extension AppTableViewCell {
    private func setupView() {
//        backgroundColor = .clear
        contentView.backgroundColor = Theme.shared.colors.appTableViewCellBackground

        setupArrow()
        setupMark()
        setupTitle()
    }

    override func prepareForReuse() {
        mark = .none
        titleLabel.text = nil
    }

    private func setupArrow() {
        contentView.addSubview(arrow)
        arrow.image = Theme.shared.images.forwardArrow

        arrow.translatesAutoresizingMaskIntoConstraints = false
        arrow.widthAnchor.constraint(equalToConstant: 8).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 13).isActive = true
        arrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        arrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
    }

    private func setupMark() {
        mark = .none
        markImageView.backgroundColor = .clear
        contentView.addSubview(markImageView)

        markImageView.translatesAutoresizingMaskIntoConstraints = false
        markImageView.widthAnchor.constraint(equalToConstant: 21).isActive = true
        markImageView.heightAnchor.constraint(equalToConstant: 21).isActive = true
        markImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        markImageView.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -12).isActive = true
    }

    private func setupTitle() {
        titleLabel.font = Theme.shared.fonts.appTableViewCell
        contentView.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: markImageView.leadingAnchor, constant: -20).isActive = true
    }
}
