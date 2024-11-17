//
//  AssetPickerCollectionViewController+ViewModel.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

import UIKit

extension AssetPickerCollectionViewController {
    enum NodeViewItem: Hashable {
        case folder(AssetFolderViewItem)
        case asset(Asset)
    }

    struct FolderViewItem: Hashable {
        let root: NodeViewItem
        let folders: [FolderViewItem]
        let assets: [NodeViewItem]

        init(root: NodeViewItem, folders: [FolderViewItem] = [], assets: [NodeViewItem] = []) {
            self.root = root
            self.folders = folders
            self.assets = assets
        }

        init(folder: AssetFolder) {
            let root: NodeViewItem = .folder(.init(folder))
            let folders: [FolderViewItem] = folder.folders.map { .init(folder: $0) }
            let assets: [NodeViewItem] = folder.assets.map { .asset($0) }

            self.init(root: root, folders: folders, assets: assets)
        }
    }
}

extension AssetPickerCollectionViewController.NodeViewItem: AssetDispalyItem {
    var displayTitle: String? {
        switch self {
        case let .folder(item):
            return item.displayTitle
        case let .asset(item):
            return item.displayTitle
        }
    }

    var displayDetails: String? {
        switch self {
        case let .folder(item):
            return item.displayDetails
        case let .asset(item):
            return item.displayDetails
        }
    }
}

extension AssetPickerCollectionViewController {
    struct AssetFolderViewItem: Hashable, AssetDispalyItem {
        let path: AssetPath

        init(_ folder: AssetFolder) {
            path = folder.path
        }

        var displayTitle: String? {
            path.last
        }

        var displayDetails: String? {
            path.description
        }
    }
}
