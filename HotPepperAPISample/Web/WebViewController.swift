//
//  WebViewController.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/15.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    static func makeFromStoryboard(shop: Shop) -> WebViewController {
        let webVC = UIStoryboard.webViewController
        webVC.urlStr = shop.urls.pc
        return webVC
    }
    
    private var urlStr: String?
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let urlStr = urlStr,
            let url = URL(string: urlStr)
        else { return }
        webView.load(URLRequest(url: url))
    }

}
