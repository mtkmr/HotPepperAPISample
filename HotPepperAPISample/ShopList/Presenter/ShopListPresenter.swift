//
//  MapPresenter.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/28.
//

import Foundation

protocol ShopListPresenterInput {
    var numberOfRowsInSection: Int { get }
    func searchShops(from keyword: String?)
    func shopData(at indexPath: IndexPath) -> Shop
}

protocol ShopListPresenterOutput: AnyObject {
    func update(shops: [Shop]?)
    func showWeb(shop: Shop)
    func handleHotPepperAPI(error: HotPepperAPIError)
    func showOKAlert(title: String, message: String)
    func startSpinner()
    func stopSpinner()
}

final class ShopListPresenter {
    private weak var output: ShopListPresenterOutput!
    private var apiClient: APIClientInput!
    private var shops: [Shop] = []
    
    init(output: ShopListPresenterOutput, apiClient: APIClientInput = APIClient.shared) {
        self.output = output
        self.apiClient = apiClient
    }
}

extension ShopListPresenter: ShopListPresenterInput {
    
    var numberOfRowsInSection: Int {
        shops.count
    }
    
    func shopData(at indexPath: IndexPath) -> Shop {
        shops[indexPath.row]
    }
    
    func searchShops(from keyword: String?) {
        guard
            let keyword = keyword, !keyword.isEmpty
        else {
            output.showOKAlert(title: "",
                               message: "キーワードを入力してください")
            return
        }
        output.startSpinner()
        apiClient.getShopData(
            parameters: HotPepperAPIParameters(keyword: keyword),
            failure: { [weak self] hotPepperError in
                self?.output.stopSpinner()
                self?.output.showOKAlert(title: "エラー",
                                         message: hotPepperError.description)
            },
            success: { [weak self] searchResults in
                self?.output.stopSpinner()
                self?.shops = searchResults.shop
                self?.output.update(shops: self?.shops)
            }
        )
    }
}
