//
//  BannerSectionModel.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/12.
//

import Foundation
import UIKit

class BannerSectionModel: SectionModel {
    // MARK: - SectionModel

    override func reusableSupplementaryViewIdentifier(elementKind: String) -> String? {
        guard elementKind == UICollectionView.elementKindSectionFooter else { return nil }
        return String(describing: BannerSupplementaryView.self.classForCoder())
    }
}
