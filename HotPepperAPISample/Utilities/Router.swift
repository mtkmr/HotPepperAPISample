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
        let mapVC = MapViewController.makeFromStoryboard()
        let nav = UINavigationController(rootViewController: mapVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        self.window = window
    }
    
    func showWeb(from: UIViewController, shop: Shop) {
        let vc = WebViewController.makeFromStoryboard(shop: shop)
        from.show(to: vc)
    }
    
}
