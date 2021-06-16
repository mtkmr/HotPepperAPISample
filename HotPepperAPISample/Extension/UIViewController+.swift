//
//  UIViewController+.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/13.
//

import UIKit

extension UIViewController {
    func show(to nextVC: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if let nav = self.navigationController {
                nav.pushViewController(nextVC, animated: animated)
                completion?()
            } else {
                self.present(nextVC, animated: true, completion: completion)
            }
        }
    }
}
