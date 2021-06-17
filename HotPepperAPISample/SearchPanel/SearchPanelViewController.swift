//
//  SearchPanelViewController.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/17.
//

import UIKit

final class SearchPanelViewController: UIViewController {
    
    static let contentViewCornerRadius: CGFloat = 40
    
    static func makeFromStoryboard() -> SearchPanelViewController {
        guard
            let vc = UIStoryboard(name: "SearchPanel", bundle: nil).instantiateInitialViewController() as? SearchPanelViewController
        else { return SearchPanelViewController() }
        return vc
    }
    
    @IBOutlet private weak var contentView: UIView! {
        didSet {
            contentView.layer.cornerRadius = Self.contentViewCornerRadius
            //角丸にしたいViewの角を指定
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
}

extension SearchPanelViewController: SemiModalPresentationManagerDelegate {
    var semiModalContentHeight: CGFloat {
        return contentView.frame.height
    }
}
