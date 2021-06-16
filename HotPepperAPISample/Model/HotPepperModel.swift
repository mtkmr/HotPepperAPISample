//
//  HotPepperModel.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/12.
//

import Foundation

struct HotPepperModel: Codable {
    let results: Results?
}

struct Results: Codable {
    let resultsAvailable: Int //全検索結果数
    let shop: [Shop] //ShopもCodableに準拠させる
}

struct Shop: Codable {
    let address: String
    let lat: Double
    let lng: Double
    let name: String
    let logoImage: String
    let urls: URLs //URLsもCodableに準拠させる
}

struct URLs: Codable {
    let pc: String
}
