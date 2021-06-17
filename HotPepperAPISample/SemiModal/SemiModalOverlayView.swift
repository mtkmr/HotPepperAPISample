//
//  SemiModalOverlayView.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/17.
//

import UIKit

final class SemiModalOverlayView: UIView {

    //アクティブなら可視化、非アクティブなら透明化
    var isActive: Bool = false {
        didSet {
            alpha = isActive ? 0.5 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
}

private extension SemiModalOverlayView {
    //初期化設定
    private func setup() {
        backgroundColor = .black
        alpha = 0.5
    }
}
