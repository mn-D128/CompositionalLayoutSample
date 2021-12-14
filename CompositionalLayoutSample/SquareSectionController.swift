//
//  SquareSectionController.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/12.
//

import UIKit

class SquareSectionController: SectionController {
    // MARK: - SectionController

    override func layoutSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let columnCount: CGFloat = 2
        let rowSpacing: CGFloat = 10
        let contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let contentWidth = layoutEnvironment.container.contentSize.width
        let cellSize = (contentWidth - (columnCount - 1) * rowSpacing - contentInsets.leading - contentInsets.trailing) / columnCount

        let cellSizeDimension = NSCollectionLayoutDimension.absolute(cellSize)
        let cellLayoutSize = NSCollectionLayoutSize(widthDimension: cellSizeDimension, heightDimension: cellSizeDimension)
        let cellLayoutItem = NSCollectionLayoutItem(layoutSize: cellLayoutSize)
        
        let rowGroupWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)
        let rowGroupLayoutSize = NSCollectionLayoutSize(
            widthDimension: rowGroupWidthDimension,
            heightDimension: cellSizeDimension
        )
        
        // グリッドの横
        let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowGroupLayoutSize, subitems: [cellLayoutItem])
        // セル間の横の余白
        rowGroup.interItemSpacing = .fixed(rowSpacing)

        let columnGroupWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)
        let columnGroupHeightDimension = NSCollectionLayoutDimension.estimated(cellSize)
        let columnGroupLayoutSize = NSCollectionLayoutSize(
            widthDimension: columnGroupWidthDimension,
            heightDimension: columnGroupHeightDimension
        )

        // グリッドの縦
        let columnGroup = NSCollectionLayoutGroup.vertical(layoutSize: columnGroupLayoutSize, subitems: [rowGroup])
        
        let section = NSCollectionLayoutSection(group: columnGroup)
        // 行間
        section.interGroupSpacing = 10
        section.contentInsets = contentInsets
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
}
