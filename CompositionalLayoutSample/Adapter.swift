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
                cellProvider: { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: CellModel) -> UICollectionViewCell? in
                    let controller = self?.sectionController(
                        at: indexPath.section,
                        dataSource: collectionView.dataSource as? UICollectionViewDiffableDataSource<SectionModel, CellModel>
                    )
                    
                    return controller?.cellForItem(at: indexPath.item)
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
                let controller = self?.sectionController(at: sectionIndex, dataSource: dataSource)
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

    private func sectionController(at sectionIndex: Int, dataSource: UICollectionViewDiffableDataSource<SectionModel, CellModel>?) -> SectionController? {
        guard let sectionIdentifier = Self.sectionIdentifier(
            dataSource: dataSource,
            sectionIndex: sectionIndex
        ) else { return nil }
        
        return self.sectionController(for: sectionIdentifier)
    }

    private func sectionController(for sectionModel: SectionModel) -> SectionController? {
        if let controller = self.sectionControllerMap[sectionModel.hashValue] {
            return controller
        }

        guard let dataSource = self.dataSource else {
            return nil
        }

        let controller = dataSource.adapter(self, sectionControllerFor: sectionModel)
        controller.collectionContext = self

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

// MARK: - CollectionContext

extension Adapter: CollectionContext {
    func dequeueReusableCell(
        withReuseIdentifier reuseIdentifier: String,
        forSectionController sectionController: SectionController,
        at index: Int
    ) -> UICollectionViewCell? {
        guard let hashValue = self.sectionControllerMap.first(where: { (_, value) in value == sectionController })?.key,
              let dataSource = self.collectionView?.dataSource as? UICollectionViewDiffableDataSource<SectionModel, CellModel>,
              let section = dataSource.snapshot().sectionIdentifiers.firstIndex(where: { $0.hashValue == hashValue }) else {
            return nil
        }
        
        return self.collectionView?.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: IndexPath(item: index, section: section)
        )
    }
}

// MARK: - 

class SectionController: NSObject {
    fileprivate(set) weak var collectionContext: CollectionContext?

    func layoutSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        nil
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        fatalError("Need to override cellForItem.")
    }

    func reusableSupplementaryViewIdentifier(elementKind: String) -> String? {
        nil
    }
}
