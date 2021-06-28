//
//  Geocoder.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/12.
//

import Foundation
import CoreLocation

enum GeocodingError: Error {
    case geocode(Error)
    case invalidAddress
    
    var description: String {
        switch self {
        case .geocode(let error):
            return "ジオコーディングエラー: \(error.localizedDescription)"
        case .invalidAddress:
            return "無効な住所が渡されました"
        }
    }
}

protocol GeocoderProtocol: AnyObject {
    func geocode(from address: String, completion: ((Result<[CLPlacemark], GeocodingError>) -> Void)?)
}

final class Geocoder: GeocoderProtocol {
    static let shared = Geocoder()
    private init() {}
    
    func geocode(from address: String, completion: ((Result<[CLPlacemark], GeocodingError>) -> Void)? = nil) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                //ジオコーディングできない住所が指定された
                completion?(.failure(.geocode(error)))
                return
            }
            guard
                let placemarks = placemarks
            else {
                completion?(.failure(.invalidAddress))
                return
            }
            completion?(.success(placemarks))
        }
    }
}

