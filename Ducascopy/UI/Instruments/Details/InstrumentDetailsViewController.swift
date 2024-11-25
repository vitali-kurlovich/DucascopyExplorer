//
//  InstrumentDetailsViewController.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 20.11.24.
//

import ComposableArchitecture
import UIKit

final class InstrumentDetailsViewController: UICollectionViewController {
    init(store: StoreOf<InstrumentsDetailsFeature> = .init(initialState: .init()) {
        InstrumentsDetailsFeature()
    }) {
        self.store = store

        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let store: StoreOf<InstrumentsDetailsFeature>
    private lazy var dataSource = makeDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
       // prepareNavigationBar()

        title = "HHHH"
        
        observe { [weak self] in
            self?.setNeedsContentUpdate()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        store.send(.willAppear)
    }
    
}

private
extension InstrumentDetailsViewController {
    enum Item: Hashable {
        case details(ItemDetails)
        case date(ItemDate)
    }

    struct ItemDetails: Hashable {
        let title: String
        let details: String
    }

    struct ItemDate: Hashable {
        let title: String
        let details: String
    }
}

private
extension InstrumentDetailsViewController {
    @MainActor
    func setNeedsContentUpdate() {
        switch store.displayState {
        case let .ready(info):
            title = info.title
        default:
            break
        }
    }

    @MainActor
    func apply(_ item: [Item], animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendItems(item)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

private
extension InstrumentDetailsViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Item>

    func makeDataSource() -> DataSource {
        let cellRegistration = cellDetailsRegistration()
        let cellDateRegistration = self.cellDateRegistration()

        return .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .date(item):
                return collectionView.dequeueConfiguredReusableCell(using: cellDateRegistration, for: indexPath, item: item)

            case let .details(item):
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
    }

    func cellDetailsRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemDetails> {
        .init { cell, _, item in

            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.secondaryText = item.details
            content.secondaryTextProperties.color = .gray

            cell.contentConfiguration = content
        }
    }

    func cellDateRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemDate> {
        .init { cell, _, item in

            var content = cell.defaultContentConfiguration()
            content.text = item.title

            // content.secondaryText = item.displayDetails
            content.secondaryTextProperties.color = .gray

            cell.contentConfiguration = content
        }
    }
}
