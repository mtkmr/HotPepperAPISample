//
//  ShopAnnotation.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/14.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphImage: UIImage? //ピンのアイコン情報
    var markerTintColor: UIColor? //ピンの色情報
    var image: UIImage? //吹き出しのimage情報
    var shopInfo: Shop
    
    init(
        coordinate: CLLocationCoordinate2D,
        title: String?,
        subtitle: String?,
        glyphImage: UIImage? = UIImage(named: "restaurant"),
        markerTintColor: UIColor? = .blue,
        image: UIImage?,
        shopInfo: Shop
    ) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphImage = glyphImage
        self.markerTintColor = markerTintColor
        self.image = image
        self.shopInfo = shopInfo
    }
}
