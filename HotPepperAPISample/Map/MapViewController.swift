//
//  MapViewController.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/12.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController {
    static func makeFromStoryboard() -> MapViewController {
        return UIStoryboard.mapViewController
    }
    
//    MARK: - property
    
    private let semiModalPresentationManager = SemiModalPresentationManager()
    
    //APIから受け取るデータ
    private var shops: [Shop] = []
    private var annotations: [CustomAnnotation] = []
    private var latitude: Double?
    private var longitude: Double?
    private let clusteringZoomLevelThreshold: Double = 18.0
    private var clusteringSwitch: Bool = true {
        didSet {
            //値が切り替わるたびにannotationを再描画する必要がある
            DispatchQueue.main.async {
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
//    MARK: - IBOutlet
    @IBOutlet private weak var searchTextField: UITextField!
    
    @IBOutlet private weak var searchButton: UIButton! {
        didSet {
            searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotationView.identifier)
        }
    }
    
//    MARK: - lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        //セミモーダルを表示
        let searchPanelVC = SearchPanelViewController.makeFromStoryboard()
        semiModalPresentationManager.viewController = searchPanelVC
        present(searchPanelVC, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

//MARK: - action method
private extension MapViewController {
    ///検索ボタンが押された
    @objc func searchButtonTapped(_ sender: UIButton) {
        guard
            let addressStr = searchTextField.text, addressStr.count > 0
        else {
            return
        }
        Geocoder.geocode(from: addressStr) { [weak self] (geocodeResult) in
            switch geocodeResult {
            case .success(let placemarks):
                let coordinate = placemarks.first?.location?.coordinate
                //中心に移動
                self?.setCenterLocation(coordinate: coordinate)
                
                self?.latitude = coordinate?.latitude
                self?.longitude = coordinate?.longitude
                let parameters = HotPepperAPIParameters(latitude: self?.latitude, longitude: self?.longitude)
                HotPepperAPI.shared.get(parameters: parameters) { (apiResult) in
                    switch apiResult {
                    case .failure(let error):
                        print(error.description)
                    case .success(let results):
                        //取得成功
                        self?.shops = results.shop
                        //マップのピンを更新
                        self?.addAnnotationOnMap(shops: self?.shops ?? [])
                    }
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }
}

//MARK: - private method
private extension MapViewController {
    
    ///縮尺と中心地の座標を設定する
    private func setCenterLocation(coordinate:  CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else { return }
        //delta: 1 = 約100kmとして
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    ///ピンをマップに立てる
    private func addAnnotationOnMap(shops: [Shop]) {
        DispatchQueue.main.async {
            //今あるマップのピンを除く
            self.mapView.removeAnnotations(self.annotations)
            //annotation配列をリセット
            self.annotations.removeAll()
            //配列に新しいピンを入れる
            shops.forEach {
                self.annotations.append(self.makeAnnotation(shop: $0))
            }
            //mapに立てる
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    ///モデルを受け取ってピンを作成して返す
    private func makeAnnotation(shop: Shop) -> CustomAnnotation {
        let annotation = CustomAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: shop.lat, longitude: shop.lng),
            title: shop.name,
            subtitle: nil,
            image: UIImage(url: shop.logoImage),
            shopInfo: shop
        )
        return annotation
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    ///annotationが追加されるときに呼ばれ、annotationViewを返す
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //mapViewがregisterしたViewを返し、作成できない場合のみ新しいViewを返す
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier, for: annotation)
        //annotationViewをキャストして作成したannotationからannotationViewへ情報を渡す
        guard
            let customAnnotationView = annotationView as? CustomAnnotationView,
              let customAnnotation = annotation as? CustomAnnotation
        else {
            return nil
        }
        //annotationViewの設定をする
        customAnnotationView.glyphImage = customAnnotation.glyphImage
        customAnnotationView.markerTintColor = customAnnotation.markerTintColor
        customAnnotationView.setClusteringIdentifier(isClustering: clusteringSwitch)
        
        //annotationViewの吹き出しの中身を設定
        //アイコン画像
        let imgView = UIImageView()
        imgView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imgView.image = customAnnotation.image
        customAnnotationView.leftCalloutAccessoryView = imgView
        //ボタン
        let btn = UIButton(type: .roundedRect)
        btn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        btn.setTitle("Webへ", for: .normal)
        btn.backgroundColor = .orange
        btn.setTitleColor(.white, for: .normal)
        customAnnotationView.rightCalloutAccessoryView = btn
        
        return customAnnotationView
    }
    
    ///吹き出しがタップされたときに呼ばれる
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotationTapped = view.annotation as! CustomAnnotation
        let shopInfo = annotationTapped.shopInfo
        Router.shared.showWeb(from: self, shop: shopInfo)
    }
    
    ///mapの表示領域が変更されたときに呼ばれる
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //ズームレベルが閾値を超えたとき、ピンのクラスタリングを解除
        if mapView.zoomLevel > clusteringZoomLevelThreshold {
            clusteringSwitch = false
        } else {
            clusteringSwitch = true
        }
    }
}
