//
//  Storyboard+.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/13.
//

import UIKit

extension UIStoryboard {
    
    static var mapViewController: MapViewController {
        UIStoryboard(name: "Map", bundle: nil).instantiateInitialViewController() as! MapViewController
    }
    
    static var webViewController: WebViewController {
        UIStoryboard(name: "Web", bundle: nil).instantiateInitialViewController() as! WebViewController
    }
}
