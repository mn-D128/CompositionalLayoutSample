//
//  ViewController.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/11.
//

import UIKit

class ViewController: UIViewController {

    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(
            SquareCell.self,
            forCellWithReuseIdentifier: String(describing: SquareCell.self.classForCoder())
        )
        view.register(
            BannerSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: String(describing: BannerSupplementaryView.self.classForCoder())
        )
        view.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .lightGray

        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            switch sectionIndex {
            case 0:
                return ViewController.createBannerLayoutSection(layoutEnvironment: layoutEnvironment)
            case 1:
                return ViewController.createSquareLayoutSection(layoutEnvironment: layoutEnvironment)
            default:
                return nil
            }
        }
        self.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)

        self.view.addSubview(self.collectionView)
        self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    // MARK: - Private

    private static func createBannerLayoutSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
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

    private static func createSquareLayoutSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
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
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: SquareCell.self.classForCoder()),
            for: indexPath
        ) as? SquareCell else {
            fatalError("no SquareCell")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch (indexPath.section, kind) {
        case (0, UICollectionView.elementKindSectionFooter):
            guard let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: String(describing: BannerSupplementaryView.self.classForCoder()),
                for: indexPath
            ) as? BannerSupplementaryView else {
                fatalError("")
            }
            return view
        default:
            fatalError("")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {}
