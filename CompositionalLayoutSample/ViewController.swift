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

    private let adapter = Adapter()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .lightGray

        self.adapter.collectionView = self.collectionView
        self.adapter.dataSource = self

        self.view.addSubview(self.collectionView)
        self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.collectionView.delegate = self
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, CellModel>()
        snapshot.appendSections([BannerSectionModel()])
        snapshot.appendItems([BannerCellModel(), BannerCellModel()])
        snapshot.appendSections([SquareSectionModel()])
        snapshot.appendItems([SquareCellModel()])
        self.adapter.apply(snapshot)
    }

// MARK: - AdapterDataSource

extension ViewController: AdapterDataSource {
    func adapter(_ adapter: Adapter, sectionControllerFor object: SectionModel) -> SectionController {
        switch object {
        case is BannerSectionModel:
            return BannerSectionController()
        case is SquareSectionModel:
            return SquareSectionController()
        default:
            fatalError("")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {}
