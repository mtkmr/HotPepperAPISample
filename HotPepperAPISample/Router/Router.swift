//
//  Router.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/12.
//

import UIKit

final class Router {
    static let shared = Router()
    private init() {}
    
    private var window: UIWindow?
    
    ///起動画面を表示する
    func showRoot(window: UIWindow?) {
        let shopListVC = ShopListViewController()
        let presenter = ShopListPresenter(output: shopListVC)
        shopListVC.inject(presenter: presenter)
        let nav = UINavigationController(rootViewController: shopListVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        self.window = window
    }
    
    func showWeb(from: UIViewController, shop: Shop) {
        let webVC = WebViewController()
        let presenter = WebPresenter(output: webVC, shop: shop)
        webVC.inject(presenter: presenter)
        from.show(to: webVC)
    }
    
}
