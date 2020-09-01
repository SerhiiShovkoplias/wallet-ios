//  OnionSettings.swift

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

import Foundation

class OnionSettings: NSObject {
    enum BridgesType: Int {
        case none
        case obfs4
        case meekazure
        case custom
    }

    class var currentlyUsedBridges: BridgesType {
        get {
            return BridgesType(rawValue: UserDefaults.standard.integer(forKey: "use_bridges")) ?? .none
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "use_bridges")
        }
    }

    class var customBridges: [String]? {
        get {
            return UserDefaults.standard.stringArray(forKey: "custom_bridges")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "custom_bridges")

        }
    }

    class var advancedTorConf: [String]? {
        get {
            return UserDefaults.standard.stringArray(forKey: "advanced_tor_conf")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "advanced_tor_conf")
        }
    }
}
