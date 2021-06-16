//
//  KeyManager.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/16.
//

import Foundation

struct KeyManager {
    private let keyFilePath = Bundle.main.path(forResource: "apiKey", ofType: "plist")
    
    //apiKey.plistのキーの辞書を取得
    private func getKeys() -> Dictionary<String, AnyObject>? {
        guard let keyFilePath = keyFilePath else { return nil }
        return NSDictionary(contentsOfFile: keyFilePath) as? Dictionary<String, AnyObject>
    }
    
    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else { return nil }
        return keys[key]
    }
}
