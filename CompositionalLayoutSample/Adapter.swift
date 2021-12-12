//
//  Adapter.swift
//  CompositionalLayoutSample
//
//  Created by Masanori Nakano on 2021/12/12.
//

import UIKit

protocol AdapterDataSource: AnyObject {
    func adapter(_ adapter: Adapter, sectionControllerFor object: SectionModel) -> SectionController
}

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

            let sectionProvider = { [weak dataSource, weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                guard let sectionIdentifier = Self.sectionIdentifier(
                    dataSource: dataSource,
                    sectionIndex: sectionIndex
                ) else { return nil }
                
                let controller = self?.sectionController(for: sectionIdentifier)
                return controller?.layoutSection(layoutEnvironment: layoutEnvironment)
            }

            newCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
            newCollectionView.dataSource = self.collectionViewDataSource
        }
    }

    weak var dataSource: AdapterDataSource?

    private var collectionViewDataSource: UICollectionViewDiffableDataSource<SectionModel, CellModel>?
    private var sectionControllerMap = [Int: SectionController]()

    // MARK: - Public

    func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<SectionModel, CellModel>,
        animatingDifferences: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let dataSource = self.collectionViewDataSource else {
            fatalError("Need a set of UICollectionView")
        }

        self.sectionControllerMap = self.sectionControllerMap
            .filter { element in
                snapshot.sectionIdentifiers.contains { element.key == $0.hashValue }
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

    private func sectionController(for sectionModel: SectionModel) -> SectionController {
        if let controller = self.sectionControllerMap[sectionModel.hashValue] {
            return controller
        }

        guard let dataSource = self.dataSource else {
            fatalError("Need a set of AdapterDataSource")
        }

        let controller = dataSource.adapter(self, sectionControllerFor: sectionModel)
        self.sectionControllerMap[sectionModel.hashValue] = controller
        return controller
    }

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
