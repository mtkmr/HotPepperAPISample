//
//  WebViewController.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/15.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private var presenter: WebPresenterInput!
    func inject(presenter: WebPresenterInput) {
        self.presenter = presenter
    }
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

}

extension WebViewController: WebPresenterOutput {
    func load(request: URLRequest) {
        webView.load(request)
    }
}
