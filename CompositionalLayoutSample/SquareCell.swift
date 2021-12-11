//
//  SquareCell.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/11.
//

import UIKit

class SquareCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.backgroundColor = .yellow
        self.contentView.layer.borderColor = UIColor.blue.cgColor
        self.contentView.layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
