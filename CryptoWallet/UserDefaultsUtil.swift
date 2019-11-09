//
//  UserDefaultsUtil.swift
//  CryptoWallet
//
//  Created by ShuichiNagao on 2019/11/10.
//  Copyright © 2019 Shuichi Nagao. All rights reserved.
//

import Foundation

struct UserDefaultsUtil {
    private static let userDefaults = UserDefaults.standard

    private enum CacheKeys: String, CaseIterable {
        case mnemonic
    }

    static var mnemonic: String {
        set {
            userDefaults.set(newValue, forKey: CacheKeys.mnemonic.rawValue)
        }
        
        get {
            return userDefaults.string(forKey: CacheKeys.mnemonic.rawValue) ?? ""
        }
    }

    
}
