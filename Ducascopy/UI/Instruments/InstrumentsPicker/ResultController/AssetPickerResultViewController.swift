//
//  AssetPickerResultViewController.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 17.11.24.
//

import UIKit

extension AssetPickerResultViewController {
    convenience init() {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.headerMode = .supplementary

        let layout = UICollectionViewCompositionalLayout.list(using: config)
        self.init(collectionViewLayout: layout)
    }
}

extension AssetPickerResultViewController.AssetsState {
    func filter(by search: String) -> Self {
        switch self {
        case .inProgress, .noResult:
            return self
        case let .groups(collection):

            if search.isEmpty {
                return self
            }

            let result = collection.map {
                $0.match(by: search)
            }.filter { !$0.isEmpty }

            if result.isEmpty {
                return .noResult
            }

            return .groups(result)
        }
    }
}

final class AssetPickerResultViewController: UICollectionViewController {
    enum AssetsState {
        case inProgress
        case groups([AssetsCollection])
        case noResult
    }

    var selectAssetHandler: ((Asset) -> Void)?

    var assetsState: AssetsState = .inProgress {
        didSet {
            invalidateResultState()
        }
    }

    var searchString: String = "" {
        didSet {
            invalidateResultState()
        }
    }

    private var resultState: AssetsState = .inProgress {
        didSet {
            setNeedsUpdateViewState()
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<AssetViewItemGroup, AssetPickerResultItem>!

    private var sections: [AssetPickerResultSection] = [] {
        didSet {
            setNeedsUpdateContent(with: sections, animatingDifferences: true)
        }
    }
}

extension AssetPickerResultViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareDataSource()
        setNeedsUpdateContent(with: sections)
    }

    override
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case let .asset(asset):
                selectAssetHandler?(asset)
            default:
                break
            }
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

private
extension AssetPickerResultViewController {
    func prepareDataSource() {
        let assetCellRegistration = assetCellRegistration()
        let loadingCellRegistration = loadingCellRegistration()

        dataSource =
            .init(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: AssetPickerResultItem) -> UICollectionViewCell? in

                switch item {
                case let .asset(asset):
                    return collectionView.dequeueConfiguredReusableCell(using: assetCellRegistration, for: indexPath, item: asset)
                case .inProgress:
                    return collectionView.dequeueConfiguredReusableCell(using: loadingCellRegistration, for: indexPath, item: item)
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
    }
}

private
extension AssetPickerResultViewController {
    func invalidateResultState() {
        resultState = assetsState.filter(by: searchString)
    }
}

private
extension AssetPickerResultViewController {
    func setNeedsUpdateContent(with sections: [AssetPickerResultSection], animatingDifferences: Bool = false) {
        if isViewLoaded {
            apply(sections, animatingDifferences: animatingDifferences)
        }
    }

    func setNeedsUpdateViewState() {
        switch resultState {
        case .inProgress:
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.loading()
            sections = []
        case let .groups(collections):
            contentUnavailableConfiguration = .none
            sections = collections.map { collection in

                let items = collection.assets.map { AssetPickerResultItem.asset($0) }
                let group = AssetViewItemGroup(id: collection.path, title: collection.title)

                return AssetPickerResultSection(group: group, items: items)
            }
        case .noResult:
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.search()
            sections = []
        }
    }

    func apply(_ sections: [AssetPickerResultSection], animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<AssetViewItemGroup, AssetPickerResultItem>()

        snapshot.appendSections(sections.map { $0.group })

        for section in sections {
            snapshot.appendItems(section.items, toSection: section.group)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

private
extension AssetPickerResultViewController {
    func assetCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Asset> {
        .init { cell, _, item in

            var content = cell.defaultContentConfiguration()
            content.text = item.displayTitle

            content.secondaryText = item.displayDetails
            content.secondaryTextProperties.color = .gray

            cell.contentConfiguration = content

//            if #available(iOS 15.4, *) {
//                cell.accessories = [.detail {
//                    let controller = AssetDetailsViewController(asset: item)
//                    controller.modalPresentationStyle = .formSheet
//                    self?.present(controller, animated: true)
//
//                }]
//            }
        }
    }

    func loadingCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, AssetPickerResultItem> {
        .init { cell, _, item in

            var content = cell.defaultContentConfiguration()
            content.text = item.displayTitle

            content.secondaryText = item.displayDetails
            content.secondaryTextProperties.color = .gray

            cell.contentConfiguration = content

            let activityView = UIActivityIndicatorView(style: .medium)
            activityView.startAnimating()

            cell.accessories = [.customView(configuration: .init(customView: activityView, placement: .trailing()))]
        }
    }

    func headerRegistration() -> UICollectionView.SupplementaryRegistration
    <UICollectionViewListCell> {
        .init(elementKind: UICollectionView.elementKindSectionHeader) {
            [unowned self] headerView, _, indexPath in

            let group = self.dataSource.sectionIdentifier(for: indexPath.section)
            var content = UIListContentConfiguration.header()
            content.text = group?.localizedTitle

            headerView.contentConfiguration = content
        }
    }
}

private
enum AssetPickerResultItem: Hashable {
    case asset(Asset)
    case inProgress
}

extension AssetPickerResultItem: AssetDispalyItem {
    var displayTitle: String? {
        switch self {
        case let .asset(asset):
            return asset.displayTitle
        case .inProgress:
            return String(localized: "Loading...", comment: "Trade screen - assets loading")
        }
    }

    var displayDetails: String? {
        switch self {
        case let .asset(asset):
            return asset.displayDetails
        case .inProgress:
            return nil
        }
    }
}

private
struct AssetViewItemGroup: Hashable {
    let id: AssetPath
    let title: String
}

extension AssetViewItemGroup {
    var localizedTitle: String? {
        title
    }
}

private
struct AssetPickerResultSection {
    let group: AssetViewItemGroup
    let items: [AssetPickerResultItem]
}
