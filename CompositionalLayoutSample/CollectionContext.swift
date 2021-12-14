//
//  CollectionContext.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/14.
//

import UIKit

protocol CollectionContext: AnyObject {
    func dequeueReusableCell(
        withReuseIdentifier reuseIdentifier: String,
        forSectionController sectionController: SectionController,
        at index: Int
    ) -> UICollectionViewCell?
}
