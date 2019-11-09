//
//  ViewController.swift
//  CryptoWallet
//
//  Created by ShuichiNagao on 2019/11/09.
//  Copyright © 2019 Shuichi Nagao. All rights reserved.
//

import UIKit
import HDWallet
import web3swift

class ViewController: UIViewController {
    
    @IBOutlet private weak var mnemonicLabel: UILabel!
    @IBOutlet private weak var ethAddressLabel: UILabel!
    @IBOutlet private weak var ethButton: UIButton!
    @IBOutlet private weak var btcButton: UIButton!
    
    private var mnemonic: String! {
        didSet {
            self.mnemonicLabel.text = mnemonic
        }
    }
    private var ethWallet: EthWallet! {
        didSet {
            self.ethAddressLabel.text = "ETH Address: \(ethWallet.address)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setWallet()
    }
    
    // MARK: - Private methods
    
    private func setWallet() {
        let mnemonic = UserDefaultsUtil.mnemonic
        if mnemonic.isEmpty {
            print("Not initialized yet")
            return
        }
        let keystore = try! BIP32Keystore(
            mnemonics: mnemonic,
            password: "",
            mnemonicsPassword: "",
            language: .english
        )!
        let name = "New HD Wallet"
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        print(address)
        self.mnemonic = mnemonic
        self.ethWallet = EthWallet(address: address, data: keyData, name: name, isHD: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func goETH(_ sender: Any) {
        if ethWallet == nil { return }
        let vc = EthereumViewController.instantiate(ethWallet: ethWallet)
        present(vc, animated: true)
    }
    
    @IBAction func goBTC(_ sender: Any) {
    }
    
    @IBAction func reset(_ sender: Any) {
        let hdwallet = HDWalletCreateWallet(nil)
        UserDefaultsUtil.mnemonic = hdwallet?.mnemonic ?? ""
        
        setWallet()
    }
}

