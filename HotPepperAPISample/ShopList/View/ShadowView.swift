//
//  ShadowView.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/08/16.
//

import UIKit

class ShadowView: UIView {

    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    private func setupShadow() {
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
                                             byRoundingCorners: .allCorners,
                                             cornerRadii: CGSize(width: 10, height: 10)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }

}
