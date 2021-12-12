//
//  SquareCellModel.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/12.
//

import Foundation

class SquareCellModel: CellModel {
    // MARK: - CellModel

    override var reuseCellIdentifier: String {
        String(describing: SquareCell.self.classForCoder())
    }
}
