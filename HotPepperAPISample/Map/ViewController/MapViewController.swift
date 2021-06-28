//
//  MapViewController.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/12.
//

import UIKit
import MapKit
import CoreLocation
import IQKeyboardManager

final class MapViewController: UIViewController {
//    MARK: - Properties
    private var annotations: [CustomAnnotation] = []
    
    private var presenter: MapPresenterInput!
    func inject(presenter: MapPresenterInput) {
        self.presenter = presenter
    }
    
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
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.backgroundImage = UIImage()
        }
    }
    
    @IBOutlet private weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
            mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotationView.identifier)
        }
    }
    
//    MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard
            let addressStr = searchBar.text, addressStr.count > 0
        else {
            return
        }
        presenter.search(address: addressStr)
        
        IQKeyboardManager.shared().resignFirstResponder()
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
        presenter.didAnnotationViewTapped(annotation: annotationTapped)
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

extension MapViewController: MapPresenterOutput {
    func setCenterLocation(coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else { return }
        //delta: 1 = 約100kmとして
        let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func update(shops: [Shop]?) {
        //mapのピンを更新する
        DispatchQueue.main.async {
            //今あるマップのピンを除く
            self.mapView.removeAnnotations(self.annotations)
            //annotation配列をリセット
            self.annotations.removeAll()
            //配列に新しいピンを入れる
            shops?.forEach {
                self.annotations.append(CustomAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: $0.lat,
                        longitude: $0.lng),
                        title: $0.name,
                        subtitle: nil,
                        image: UIImage(url: $0.logoImage),
                        shopInfo: $0))
            }
            //mapに立てる
            self.mapView.addAnnotations(self.annotations)
        }
    }
    
    func showWeb(shop: Shop) {
        Router.shared.showWeb(from: self, shop: shop)
    }
    
    func handleGeocoding(error: GeocodingError) {
        print(error.description)
    }
    
    func handleHotPepperAPI(error: HotPepperAPIError) {
        print(error.description)
    }
}
