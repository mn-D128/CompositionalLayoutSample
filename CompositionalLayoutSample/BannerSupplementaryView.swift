//
//  BannerSupplementaryView.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/11.
//

import UIKit

class BannerSupplementaryView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
