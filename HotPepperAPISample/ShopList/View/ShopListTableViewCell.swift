//
//  ShopListTableViewCell.swift
//  HotPepperAPISample
//
//  Created by Masato Takamura on 2021/08/16.
//

import UIKit

class ShopListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        nameLabel.text = nil
        genreLabel.text = nil
        addressLabel.text = nil
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        DispatchQueue.main.async {
            self.shadowView.backgroundColor = highlighted ? .lightGray : .secondarySystemGroupedBackground
        }
    }
    
    func configure(shop: Shop) {
        iconImageView.image = UIImage(url: shop.logoImage)
        nameLabel.text = shop.name
        genreLabel.text = shop.genre.name
        addressLabel.text = shop.address
    }
    
}
