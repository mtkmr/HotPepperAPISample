//
//  MapPresenter.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/28.
//

import Foundation
import CoreLocation //presenterから切り離したいが、、

protocol MapPresenterInput {
    ///hotpepper apiからデータを取得する
    func search(address: String)
    
    ///ピンの吹き出しがタップされたときの処理
    func didAnnotationViewTapped(annotation: CustomAnnotation)
    
}

protocol MapPresenterOutput: AnyObject {
    ///縮尺と中心地の座標を設定する
    func setCenterLocation(coordinate: CLLocationCoordinate2D?)
    ///Shopデータを受け取って何らかのupdateする
    func update(shops: [Shop]?)
    ///Web画面へ移動する
    func showWeb(shop: Shop)
    ///エラーハンドル
    func handleHotPepperAPI(error: HotPepperAPIError)
    func handleGeocoding(error: GeocodingError)
}


///MapViewのプレゼンテーションロジックを処理するオブジェクト
final class MapPresenter {
    private var latitude: Double?
    private var longitude: Double?
    private var shops: [Shop] = []
    private weak var output: MapPresenterOutput!
    private var api: HotPepperAPIProtocol!
    private var geocoder: GeocoderProtocol!
    
    init(output: MapPresenterOutput, geocoder: GeocoderProtocol = Geocoder.shared, api: HotPepperAPIProtocol = HotPepperAPI.shared) {
        self.output = output
        self.geocoder = geocoder
        self.api = api
    }
    
}

extension MapPresenter: MapPresenterInput {
    
    func search(address: String) {
        geocoder.geocode(from: address) { [weak self] (geocodeResult) in
            switch geocodeResult {
            case .success(let placemarks):
                let coordinate = placemarks.first?.location?.coordinate
                //mapの中心を移動する
                self?.output.setCenterLocation(coordinate: coordinate)
                
                self?.latitude = coordinate?.latitude
                self?.longitude = coordinate?.longitude
                let parameters = HotPepperAPIParameters(latitude: self?.latitude, longitude: self?.longitude)
                self?.api.get(parameters: parameters) { (apiResult) in
                    switch apiResult {
                    case .failure(let error):
                        self?.output.handleHotPepperAPI(error: error)
                        
                    case .success(let results):
                        self?.shops = results.shop
                        //マップのピンを更新
                        self?.output.update(shops: self?.shops)
                    }
                }
            case .failure(let error):
                self?.output.handleGeocoding(error: error)
            }
        }
    }
    
    func didAnnotationViewTapped(annotation: CustomAnnotation) {
        let shopInfo = annotation.shopInfo
        output.showWeb(shop: shopInfo)
    }
}
