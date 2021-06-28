//
//  WebPresenter.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/28.
//

import Foundation

protocol WebPresenterInput {
    func viewDidLoad()
}

protocol WebPresenterOutput: AnyObject {
    func load(request: URLRequest)
}

final class WebPresenter {
    private weak var output: WebPresenterOutput!
    private var shop: Shop
    
    init(output: WebPresenterOutput, shop: Shop) {
        self.output = output
        self.shop = shop
    }
}

extension WebPresenter: WebPresenterInput {
    func viewDidLoad() {
        let urlStr = shop.urls.pc
        guard
            let url = URL(string: urlStr)
        else { return }
        //webViewをロード
        output.load(request: URLRequest(url: url))
    }
}
