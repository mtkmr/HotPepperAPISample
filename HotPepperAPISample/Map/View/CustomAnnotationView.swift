//
//  ShopClusterAnnotationView.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/14.
//

import Foundation
import MapKit

class CustomAnnotationView: MKMarkerAnnotationView {
    //リユースidentifier
    static var identifier: String { String(describing: Self.self) }
    //annotationViewがmapに表示されることを通知する。
    //このメソッドでannotationViewの内容で準備できるものはする
    override func prepareForDisplay() {
        super.prepareForDisplay()
        //吹き出し表示するトリガー
        canShowCallout = true
    }
    
    ///クラスタリングidentifierの設定
    func setClusteringIdentifier(isClustering: Bool) {
        self.clusteringIdentifier = isClustering ? String(describing: Self.self) : nil
    }

}
