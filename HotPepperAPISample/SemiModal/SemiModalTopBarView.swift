//
//  SemiModalTopBarView.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/17.
//

import UIKit

final class SemiModalTopBarView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
}

private extension SemiModalTopBarView {
    ///初期化設定
    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = 5.0
        backgroundColor = .lightGray
    }
}
