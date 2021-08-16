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
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.color = .lightGray
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopSpinner()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        stopSpinner()
        Alert.okAlert(title: "エラー",
                      message: "読み込みに失敗しました",
                      on: self)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        stopSpinner()
        Alert.okAlert(title: "エラー",
                      message: "通信環境を確認してください",
                      on: self)
    }
}

extension WebViewController: WebPresenterOutput {
    func startSpinner() {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
    }
    
    func stopSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
}
