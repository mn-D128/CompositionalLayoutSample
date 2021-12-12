//
//  Adapter.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/12.
//

import UIKit

class Adapter: NSObject {
    weak var collectionView: UICollectionView? {
        willSet {
            guard let newCollectionView = newValue else {
                self.collectionView?.dataSource = nil
                self.collectionViewDataSource = nil
                return
            }
            
            let dataSource = UICollectionViewDiffableDataSource<SectionModel, CellModel>(
                collectionView: newCollectionView,
                cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: CellModel) -> UICollectionViewCell? in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier.reuseCellIdentifier, for: indexPath)
                    return cell
                }
            )

            self.collectionViewDataSource = dataSource

            dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, elementKind: String, indexPath: IndexPath) -> UICollectionReusableView? in
                guard let sectionIdentifier = Self.sectionIdentifier(
                    dataSource: collectionView.dataSource as? UICollectionViewDiffableDataSource<SectionModel, CellModel>,
                    sectionIndex: indexPath.section
                ) else { return nil }
                      
                guard let reuseIdentifier = sectionIdentifier.reusableSupplementaryViewIdentifier(elementKind: elementKind) else { return nil }
                
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: reuseIdentifier,
                    for: indexPath
                )
                return view
            }

            let sectionProvider = { [weak dataSource] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                let sectionIdentifier = Self.sectionIdentifier(
                    dataSource: dataSource,
                    sectionIndex: sectionIndex
                )
                return sectionIdentifier?.layoutSection(layoutEnvironment: layoutEnvironment)
            }

            newCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
            newCollectionView.dataSource = self.collectionViewDataSource
        }
    }

    private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, CellModel>?

    // MARK: - Public

    func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<SectionModel, CellModel>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let dataSource = self.collectionViewDataSource else {
            fatalError("Need a set of UICollectionView")
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    func snapshot() -> NSDiffableDataSourceSnapshot<SectionModel, CellModel> {
        guard let dataSource = self.collectionViewDataSource else {
            fatalError("Need a set of UICollectionView")
        }

        return dataSource.snapshot()
    }

    // MARK: - Private

    private static func sectionIdentifier(dataSource: UICollectionViewDiffableDataSource<SectionModel, CellModel>?, sectionIndex: Int) -> SectionModel? {
        if #available(iOS 15.0, *) {
            return dataSource?.sectionIdentifier(for: sectionIndex)
        }

        guard let sectionIdentifiers = dataSource?.snapshot().sectionIdentifiers,
              sectionIdentifiers.indices.contains(sectionIndex) else {
            return nil
        }
        
        return sectionIdentifiers[sectionIndex]
    }
}
