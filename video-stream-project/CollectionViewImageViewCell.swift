//  Converted to Swift 5.2 by Swiftify v5.2.23024 - https://swiftify.com/
//
//  SGSImageViewCell.h
//  SGSMultipeerVideoMixer
//
//  Created by PJ Gray on 12/30/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

//
//  SGSImageViewCell.m
//  SGSMultipeerVideoMixer
//
//  Created by PJ Gray on 12/30/13.
//  Copyright (c) 2013 Say Goodnight Software. All rights reserved.
//

import UIKit

class CollectionViewImageViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}