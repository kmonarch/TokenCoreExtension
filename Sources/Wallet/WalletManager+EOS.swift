//
//  WalletManager+EOS.swift
//  TokenCore
//
//  Created by James Chen on 2018/06/22.
//  Copyright © 2018 ConsenLabs. All rights reserved.
//

import Foundation

public extension WalletManager {
  static let eosPubKeyDicKey = "eosPubKeyDicKey" //userDefault中eos钱包映射字典获取需要的key
  public static func importEOS(
    from mnemonic: String,
    accountName: String,
    permissions: [EOS.PermissionObject],
    metadata: WalletMeta,
    encryptBy password: String,
    at path: String
  ) throws -> BasicWallet {
    let identity = try IdentityValidator().validate()
    return try identity.importEOS(from: mnemonic, accountName: accountName, permissions: permissions, metadata: metadata, encryptBy: password, at: path)
  }

  public static func importEOS(
    from privateKeys: [String],
    accountName: String,
    permissions: [EOS.PermissionObject],
    encryptedBy password: String,
    metadata: WalletMeta
  ) throws -> BasicWallet {
    let identity = try IdentityValidator().validate()
    return try identity.importEOS(from: privateKeys, accountName: accountName, permissions: permissions, encryptedBy: password, metadata: metadata)
  }

  public static func setEOSAccountName(walletID: String, accountName: String) throws -> BasicWallet {
    let wallet = try findWalletByWalletID(walletID)

    if wallet.imTokenMeta.chain != .eos {
      throw GenericError.operationUnsupported
    }

    guard var keystore = wallet.keystore as? EOSKeystore else {
      throw GenericError.operationUnsupported
    }

    try keystore.setAccountName(accountName)
    wallet.keystore = keystore
    if !Identity.storage.flushWallet(keystore) {
      throw GenericError.storeWalletFailed
    }

    return wallet
  }

  public static func exportPrivateKeys(walletID: String, password: String) throws -> [KeyPair] {
    guard let wallet = Identity.currentIdentity?.findWalletByWalletID(walletID) else {
      throw GenericError.walletNotFound
    }

    return try wallet.privateKeys(password: password)
  }

  /// Sign EOS transaction
  /// - Parameters:
  ///   - walletID: Wallet ID.
  ///   - txs: Array of EOSTransaction.
  ///   - password: Wallet password.
  public static func eosSignTransaction(
    walletID: String,
    txs: [EOSTransaction],
    password: String
    ) throws -> [EOSSignResult] {
    guard let wallet = Identity.currentIdentity?.findWalletByWalletID(walletID) else {
      throw GenericError.walletNotFound
    }

    return try EOSTransactionSigner(txs: txs, keystore: wallet.keystore, password: password).sign()
  }

  // MARK: bing/load pubKey
  public static func bingPubKey(walletID: String, password: String) throws {
    let exportedKeys = try WalletManager.exportPrivateKeys(walletID: walletID, password: password)
    var pubkeys = UserDefaults.standard.dictionary(forKey: eosPubKeyDicKey)
    if pubkeys != nil {
      pubkeys![walletID] = exportedKeys[0].publicKey
    } else {
      pubkeys = [walletID: exportedKeys[0].publicKey]

    }
    UserDefaults.standard.set(pubkeys, forKey: eosPubKeyDicKey)
  }

  public static func loadPubKey(walletID: String) -> String? {
    var pubkeys = UserDefaults.standard.dictionary(forKey: eosPubKeyDicKey)
    guard pubkeys != nil && pubkeys![walletID] != nil else {
      return nil
    }
    return (pubkeys![walletID] as! String)
  }

}
