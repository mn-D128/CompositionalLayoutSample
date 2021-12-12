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
                self.dataSource = nil
                self._collectionViewLayout = nil
                return
            }
            
            let dataSource = UICollectionViewDiffableDataSource<SectionModel, CellModel>(
                collectionView: newCollectionView,
                cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: CellModel) -> UICollectionViewCell? in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier.reuseCellIdentifier, for: indexPath)
                    return cell
                }
            )

            self.dataSource = dataSource

            dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, elementKind: String, indexPath: IndexPath) -> UICollectionReusableView? in
                guard let sectionIdentifier = (collectionView.dataSource as? UICollectionViewDiffableDataSource<SectionModel, CellModel>)?.sectionIdentifier(for: indexPath.section),
                      let reuseIdentifier = sectionIdentifier.reusableSupplementaryViewIdentifier(elementKind: elementKind) else {
                    return nil
                }
                
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: reuseIdentifier,
                    for: indexPath
                )
                return view
            }

            let sectionProvider = { [weak dataSource] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                let sectionIdentifier = dataSource?.sectionIdentifier(for: sectionIndex)
                return sectionIdentifier?.layoutSection(layoutEnvironment: layoutEnvironment)
            }

            self._collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        }
    }

    private(set) var dataSource: UICollectionViewDiffableDataSource<SectionModel, CellModel>?
    private var _collectionViewLayout: UICollectionViewCompositionalLayout?
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        guard let layout = self._collectionViewLayout else {
            fatalError("")
        }

        return layout
    }
}
