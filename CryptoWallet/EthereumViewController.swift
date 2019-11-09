//
//  EthereumViewController.swift
//  CryptoWallet
//
//  Created by ShuichiNagao on 2019/11/09.
//  Copyright © 2019 Shuichi Nagao. All rights reserved.
//

import UIKit
import web3swift

struct EthWallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
}

struct ERC20Token {
    var name: String
    var address: String
    var decimals: String
    var symbol: String
}

class EthereumViewController: UIViewController {

    private var ethWallet: EthWallet!
    private var keystoreManager: KeystoreManager!
    private var web3: web3!
    
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var ethAddressTextView: UITextView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var qrCodeView: QRCodeImageView!
    
    static func instantiate(ethWallet: EthWallet) -> EthereumViewController {
        let sb = UIStoryboard(name: "Ethereum", bundle: Bundle(for: EthereumViewController.self))
        let vc = sb.instantiateInitialViewController() as! EthereumViewController
        vc.ethWallet = ethWallet
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        web3SetUp()
        ethAddressTextView.text = ethWallet.address
        qrCodeView.updateQrImage(urlString: ethWallet.address)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getBalance()
    }
    
    // MARK: - Private methods
    
    private func web3SetUp() {
        let data = ethWallet.data
        if ethWallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        web3 = Web3.InfuraRopstenWeb3()
        web3.addKeystoreManager(keystoreManager)
    }
    
    private func getBalance() {
        let walletAddress = EthereumAddress(ethWallet.address)!
        let balanceResult = try! web3.eth.getBalance(address: walletAddress)
        let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
        balanceLabel.text = "\(balanceString) ETH"
    }
    
    private func sendEth(value: String, to: String) {
        let walletAddress = EthereumAddress(ethWallet.address)! // Your wallet address
        let toAddress = EthereumAddress(to)!
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = TransactionOptions.defaultOptions
        options.value = amount
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        let tx = contract.write(
            "fallback",
            parameters: [AnyObject](),
            extraData: Data(),
            transactionOptions: options
        )!
        let result = try! tx.send(password: "")
        print(result.hash)
    }
    
    private func sendERC20(to: String) {
        let value: String = "1.0" // In Tokens
        let walletAddress = EthereumAddress(ethWallet.address)! // Your wallet address
        let toAddress = EthereumAddress(to)!
        let token = ERC20Token(name: "JB Coin", address: "", decimals: "18", symbol: "JBC")
        let erc20ContractAddress = EthereumAddress(token.address)!
        let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = TransactionOptions.defaultOptions
        options.value = amount
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        let method = "transfer"
        let tx = contract.write(
            method,
            parameters: [toAddress, amount] as [AnyObject],
            extraData: Data(),
            transactionOptions: options
        )!
        let result = try! tx.send(password: "")
        print(result.hash)
    }
    
    // MARK: - Private methods
    
    @IBAction func send(_ sender: Any) {
        guard let value = amountTextField.text else { return }
        sendEth(value: value, to: "0x81b7e08f65bdf5648606c89998a9cc8164397647")
    }
}
