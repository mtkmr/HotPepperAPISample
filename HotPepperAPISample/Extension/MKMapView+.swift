//
//  MKMapView+.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/14.
//

import Foundation
import MapKit

extension MKMapView {
    //ズームレベル: 縦横128ポイントのパネルが何枚で表示できるか (2^xのxのこと)
    var zoomLevel: Double {
        return log2(360 * Double(self.frame.size.width) / 128 / (self.region.span.longitudeDelta))
    }
}
