//
//  AssetsCollection.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 17.11.24.
//

struct AssetsCollection: Hashable {
    let title: String
    let path: AssetPath
    let assets: [Asset]
}

extension AssetsCollection {
    var isEmpty: Bool {
        assets.isEmpty
    }
}

extension AssetsCollection {
    init(_ folder: AssetFolder) {
        self.init(title: folder.title, path: folder.path, assets: folder.allAssets)
    }
}

extension AssetsCollection {
    func match(by searchString: String) -> Self {
        let assets = self.assets.match(by: searchString)
        return .init(title: title, path: path, assets: assets)
    }
}
