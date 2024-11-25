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
        let date: Date
    }

    enum Section: Hashable {
        case basic
        case currency
        case history
        case tags

        var title: String {
            switch self {
            case .basic:
                return "Info"
            case .history:
                return "History"
            case .currency:
                return "Currency"
            case .tags:
                return "Tags"
            }
        }
    }
}

private
extension InstrumentDetailsViewController {
    @MainActor
    func setNeedsContentUpdate() {
        switch store.displayState {
        case let .ready(info):
            title = info.title
            apply(info, animatingDifferences: true)
        default:
            break
        }
    }

    @MainActor
    func apply(_ info: InstrumetInfo, animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        snapshot.appendSections([.basic, .currency, .history])

        let fileInfo = info.fileInfo

        let basicItems = [
            ItemDetails(title: info.name, details: info.description),
            ItemDetails(title: "Filename", details: fileInfo.filename),
        ]

        snapshot.appendItems(basicItems.map { .details($0) }, toSection: .basic)

        let currency = info.currency

        let currencyItems = [
            ItemDetails(title: "Base", details: currency.base),
            ItemDetails(title: "Quote", details: currency.quote),
            ItemDetails(title: "PipValue", details: info.pipValue.formatted()),
            ItemDetails(title: "Special", details: info.special ? "Yes" : "No"),
        ]

        snapshot.appendItems(currencyItems.map { .details($0) }, toSection: .currency)

        let historyDate = fileInfo.historyDate

        let historyItems = [
            ItemDate(title: "Ticks", date: historyDate.start_tick),
            ItemDate(title: "10 sec", date: historyDate.start_10sec),
            ItemDate(title: "Minute", date: historyDate.start_60sec),
            ItemDate(title: "Hour", date: historyDate.start_60min),
            ItemDate(title: "Day", date: historyDate.start_day),
        ]

        snapshot.appendItems(historyItems.map { .date($0) }, toSection: .history)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

private
extension InstrumentDetailsViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>

    func makeDataSource() -> DataSource {
        let cellRegistration = cellDetailsRegistration()
        let cellDateRegistration = self.cellDateRegistration()

        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .date(item):
                return collectionView.dequeueConfiguredReusableCell(using: cellDateRegistration, for: indexPath, item: item)

            case let .details(item):
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }

        let headerRegistration = self.headerRegistration()

        dataSource.supplementaryViewProvider = {
            collectionView, _, indexPath -> UICollectionReusableView? in

            // Dequeue header view
            collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration, for: indexPath
            )
        }

        return dataSource
    }

    func cellDetailsRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemDetails> {
        .init { cell, _, item in

            var content =  UIListContentConfiguration.valueCell()
            content.text = item.title
            content.secondaryText = item.details
            content.secondaryTextProperties.color = .gray

            cell.contentConfiguration = content
        }
    }

    func cellDateRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemDate> {
        .init { cell, _, item in

            var content = UIListContentConfiguration.valueCell()
            content.text = item.title
            content.secondaryText = item.date.formatted()
            // content.secondaryText = item.displayDetails
            content.secondaryTextProperties.color = .gray

            cell.contentConfiguration = content
        }
    }

    func headerRegistration() -> UICollectionView.SupplementaryRegistration
    <UICollectionViewListCell> {
        .init(elementKind: UICollectionView.elementKindSectionHeader) {
            [unowned self] headerView, _, indexPath in

            let section = self.dataSource.sectionIdentifier(for: indexPath.section)
            var content = UIListContentConfiguration.header()
            content.text = section?.title
            headerView.contentConfiguration = content
        }
    }
}
