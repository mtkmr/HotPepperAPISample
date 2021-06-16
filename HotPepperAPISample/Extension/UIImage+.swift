//
//  UIImage+.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/06/15.
//

import UIKit

extension UIImage {
    public convenience init(url: String){
        let url = URL(string: url)
        do {
            if let url = url{
                let data = try Data(contentsOf: url)
                self.init(data: data)!
                return
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        self.init()
    }
}
