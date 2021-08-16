//
//  MapViewController.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/12.
//

import UIKit

final class ShopListViewController: UIViewController {
//    MARK: - Properties
    private var presenter: ShopListPresenterInput!
    func inject(presenter: ShopListPresenterInput) {
        self.presenter = presenter
    }
    //    MARK: - UI Parts
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.sizeToFit()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "キーワードを入力してください"
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemOrange
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: ShopListTableViewCell.className,
                  bundle: nil),
            forCellReuseIdentifier: ShopListTableViewCell.className
        )
        return tableView
        
    }()
    
    private lazy var emptyLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .systemPurple
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.text = "上の検索窓に\nキーワードを入力して\nお店を探してください。\n例) 東京駅、焼肉、居酒屋など"
        
        return label
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.style = .large
        spinner.color = .lightGray
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    //    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        //searchBarをセット
        navigationItem.titleView = searchBar
        // navigationBarの背景色
        navigationController?.navigationBar.barTintColor = .systemBackground
        // navigationBarのitemの色
        navigationController?.navigationBar.tintColor = .label
        // navigationBarのテキスト
        navigationController?.navigationBar.titleTextAttributes = [
            // テキストの色
            .foregroundColor: UIColor.label
        ]
        
        updateView(isEmpty: true)
    }
}

private extension ShopListViewController {
    func activate(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.searchBar.showsCancelButton = true
        }
    }
    
    func deactivate(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.searchBar.showsCancelButton = false
            self.searchBar.endEditing(true)
        }
    }
    
    func updateView(isEmpty: Bool) {
        DispatchQueue.main.async {
            self.tableView.isHidden = isEmpty
            self.emptyLabel.isHidden = !isEmpty
        }
    }
    
}

//MARK: - UISearchBarDelegate
extension ShopListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchShops(from: searchBar.text)
        deactivate(searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activate(searchBar)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        deactivate(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        deactivate(searchBar)
    }
    
}

//MARK: - UITableViewDelegate
extension ShopListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRow(at: indexPath)
    }
    
}

//MARK: - UITableViewDataSource
extension ShopListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ShopListTableViewCell.className,
            for: indexPath) as! ShopListTableViewCell
        cell.isHighlighted = false
        let shopData = presenter.shopData(at: indexPath)
        cell.configure(shop: shopData)
        
        return cell
    }
    
}

//MARK: - MKMapViewDelegate

extension ShopListViewController: ShopListPresenterOutput {
    
    func update(shops: [Shop]?) {
        if let shops = shops, !shops.isEmpty {
            updateView(isEmpty: false)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showWeb(shop: Shop) {
        Router.shared.showWeb(from: self, shop: shop)
    }
   
    
    func handleHotPepperAPI(error: HotPepperAPIError) {
        print(error.description)
    }
    
    func showOKAlert(title: String, message: String) {
        Alert.okAlert(title: title, message: message, on: self)
    }
    
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
}
