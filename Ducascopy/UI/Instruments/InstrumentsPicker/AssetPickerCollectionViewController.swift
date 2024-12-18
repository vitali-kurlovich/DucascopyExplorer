//
//  AssetPickerCollectionViewController.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

import ComposableArchitecture
import UIKit

final class AssetPickerCollectionViewController: UICollectionViewController {
    private let store: StoreOf<InstrumentsFeature>

    init(store: StoreOf<InstrumentsFeature> = .init(initialState: .init()) {
        InstrumentsFeature()
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

    var selectAssetHandler: ((Asset) -> Void)? {
        didSet {
            resultViewController.selectAssetHandler = selectAssetHandler
        }
    }

    private lazy var dataSource = makeDataSource()
    private lazy var resultViewController = makeResultController()
    private lazy var searchController = makeSearchViewController()

    private var folders: [AssetFolder] = [] {
        didSet {
            if oldValue != folders {
                folderView = folders.map { .init(folder: $0) }

                let groups = folders.map { root in
                    AssetsCollection(root)
                }

                resultViewController.assetsState = .groups(groups)
            }
        }
    }

    private var folderView: [FolderViewItem] = [] {
        didSet {
            if oldValue != folderView {
                setNeedsContentUpdate()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Asset"
        definesPresentationContext = true
        prepareNavigationBar()

        observe { [weak self] in
            self?.setNeedsUpdateState()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        store.send(.willAppear)
    }

    override
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectAssetHandler, let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case let .asset(asset):
                selectAssetHandler(asset)
            default:
                break
            }
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

private
extension AssetPickerCollectionViewController {
    @MainActor
    func setNeedsUpdateState() {
        switch store.loading {
        case .none:
            contentUnavailableConfiguration = .none
        case .inProgress:
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.loading()
        case let .error(description):
            var configuration = UIContentUnavailableConfiguration.empty()
            configuration.image = UIImage(systemName: "figure.roll")
            configuration.text = "Error..."
            configuration.secondaryText = description
            contentUnavailableConfiguration = configuration
        case let .ready(folders):
            contentUnavailableConfiguration = .none
            self.folders = folders
        }
    }
}

private
extension AssetPickerCollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, NodeViewItem>

    func makeDataSource() -> DataSource {
        let cellRegistration = self.cellRegistration()
        let folderRegistration = self.folderRegistration()

        return .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .asset(asset):
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: asset)
            case let .folder(folder):
                return collectionView.dequeueConfiguredReusableCell(using: folderRegistration, for: indexPath, item: folder)
            }
        }
    }

    func makeResultController() -> AssetPickerResultViewController {
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.headerMode = .supplementary

        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)

        return AssetPickerResultViewController(collectionViewLayout: listLayout)
    }
}

private
extension AssetPickerCollectionViewController {
    func cellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Asset> {
        .init { cell, _, item in

            var content = cell.defaultContentConfiguration()
            content.text = item.displayTitle

            content.secondaryText = item.displayDetails
            content.secondaryTextProperties.color = .gray

            cell.contentConfiguration = content

            cell.accessories = [.detail { [weak self] in
                let info = item.info

                let state = InstrumentsDetailsFeature.State(displayState: .ready(info))
                let store = StoreOf<InstrumentsDetailsFeature>(initialState: state, reducer: {})

                let detailsController = InstrumentDetailsViewController(store: store)
                detailsController.modalPresentationStyle = .formSheet

                let controller = UINavigationController(rootViewController: detailsController)

                self?.present(controller, animated: true)

            }]
        }
    }

    func folderRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, AssetFolderViewItem> {
        .init { cell, _, item in

            var content = cell.defaultContentConfiguration()
            content.text = item.displayTitle

            content.secondaryText = item.displayDetails
            content.secondaryTextProperties.color = .gray

            content.image = UIImage(systemName: "folder")

            cell.contentConfiguration = content

            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: disclosureOptions)]
        }
    }
}

private
extension AssetPickerCollectionViewController {
    @MainActor
    func setNeedsContentUpdate() {
        apply(folderView, animatingDifferences: true)
    }

    @MainActor
    func apply(_ folders: [FolderViewItem], animatingDifferences: Bool = false) {
        var snapshot = self.snapshot(folders: folders)
        let source = dataSource.snapshot(for: 0)
        let items = source.items
        let expanded = items.filter { source.isExpanded($0) }
        snapshot.expand(expanded)

        dataSource.apply(snapshot, to: 0, animatingDifferences: animatingDifferences)
    }
}

private
extension AssetPickerCollectionViewController {
    func makeSearchViewController() -> UISearchController {
        let controller = UISearchController(searchResultsController: resultViewController)
        controller.searchResultsUpdater = self
        controller.searchBar.autocapitalizationType = .words
        controller.searchBar.delegate = self

        return controller
    }
}

extension AssetPickerCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension AssetPickerCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text

        resultViewController.searchString = searchString ?? ""
    }
}

private
extension AssetPickerCollectionViewController {
    func snapshot(folders: [FolderViewItem]) -> NSDiffableDataSourceSectionSnapshot<NodeViewItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<NodeViewItem>()

        func append(_ items: [NodeViewItem], to parent: NodeViewItem?) {
            guard !items.isEmpty else {
                return
            }

            snapshot.append(items, to: parent)
        }

        func append(folders: [FolderViewItem], to parent: NodeViewItem?) {
            guard !folders.isEmpty else {
                return
            }

            let items = folders.map { $0.root }
            append(items, to: parent)

            for folder in folders {
                append(folder.assets, to: folder.root)

                append(folders: folder.folders, to: folder.root)
            }
        }

        append(folders: folders, to: nil)

        return snapshot
    }
}

private
extension AssetPickerCollectionViewController {
    func prepareNavigationBar() {
        navigationItem.searchController = searchController

        let closeAction = UIAction { [unowned self] _ in
            self.dismiss(animated: true)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: closeAction)

        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}
