//
//  BannerSectionController.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/12.
//

import UIKit

class BannerSectionController: SectionController {
    // MARK: - SectionController

    override func layoutSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let edgeSpacing: CGFloat = 10
        let contentWidth = layoutEnvironment.container.contentSize.width
        let cellWidth = contentWidth - edgeSpacing * 2
        let cellHeightLayoutDimension = NSCollectionLayoutDimension.absolute(100)
        
        let groupLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: cellHeightLayoutDimension
        )

        let cellLayoutSize = NSCollectionLayoutSize(
            widthDimension: .absolute(cellWidth),
            heightDimension: cellHeightLayoutDimension
        )
        let cellLayoutItem = NSCollectionLayoutItem(layoutSize: cellLayoutSize)
        cellLayoutItem.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: .fixed(edgeSpacing),
            top: nil,
            trailing: .fixed(edgeSpacing),
            bottom: nil
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupLayoutSize, subitems: [cellLayoutItem])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let supplementaryItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(44)
        )
        let supplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: supplementaryItemSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [supplementaryItem]

        return section
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = self.collectionContext?.dequeueReusableCell(
            withReuseIdentifier: String(describing: SquareCell.self.classForCoder()),
            forSectionController: self,
            at: index
        ) else {
            fatalError("cell")
        }

        return cell
    }

    override func reusableSupplementaryViewIdentifier(elementKind: String) -> String? {
        guard elementKind == UICollectionView.elementKindSectionFooter else { return nil }
        return String(describing: BannerSupplementaryView.self.classForCoder())
    }
}
