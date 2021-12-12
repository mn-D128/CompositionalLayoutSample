//
//  BannerCellModel.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/12.
//

import Foundation

class BannerCellModel: CellModel {
    override var reuseCellIdentifier: String {
        String(describing: SquareCell.self.classForCoder())
    }
}
