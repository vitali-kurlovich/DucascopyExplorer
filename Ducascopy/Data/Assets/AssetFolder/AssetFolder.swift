//
//  AssetFolder.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

public
struct AssetFolder: Hashable {
    public let title: String
    public let path: AssetPath
    public let folders: [AssetFolder]
    public let assets: [Asset]
}

public
extension AssetFolder {
    var name: String? {
        path.last
    }
}

extension AssetFolder: Comparable {
    public static func < (lhs: AssetFolder, rhs: AssetFolder) -> Bool {
        lhs.path < rhs.path
    }
}

public
extension AssetFolder {
    var foldersCount: Int {
        var count = folders.count
        count = folders.reduce(count) { partialResult, folder in
            partialResult + folder.foldersCount
        }
        return count
    }

    var assetsCount: Int {
        var count = assets.count
        count = folders.reduce(count) { partialResult, folder in
            partialResult + folder.assetsCount
        }
        return count
    }
}

public
extension AssetFolder {
    var allAssets: [Asset] {
        extractAllAssets(from: self)
    }

    private func extractAllAssets(from folder: AssetFolder) -> [Asset] {
        folder.assets + folder.folders.flatMap { extractAllAssets(from: $0) }
    }
}

extension [AssetFolder] {
    init(_ collection: InstrumentsCollection) {
        let groups = collection.groups
        let instruments = collection.instruments

        func groupAssets(for group: AssetGroup, basePath: AssetPath) -> [Asset] {
            let path = basePath.append(group.id)

            return group.instruments?.compactMap { id -> Asset? in
                guard let instrumet = instruments[id],
                      !(instrumet.historical_filename?.isEmpty ?? true)
                else { return nil }

                let path = path.setQuery(.init(["symbol": id]))
                return Asset(instrumet, id: id, path: path)
            } ?? []
        }

        func childFolders(parentId: String, basePath: AssetPath) -> [AssetFolder] {
            let childGroups = groups.values.lazy.filter { $0.parent == parentId }

            return childGroups.map { group in
                let path = basePath.append(group.id)
                let folders = childFolders(parentId: group.id, basePath: path)
                let assets = groupAssets(for: group, basePath: basePath)

                let title = group.title

                return AssetFolder(title: title, path: path, folders: folders, assets: assets)
            }
        }

        let roots = groups.values.filter { $0.parent == nil }
        let rootPath = AssetPath(path: [])

        let folders = roots.map { group -> AssetFolder in

            let path = rootPath.append(group.id)

            let folders = childFolders(parentId: group.id, basePath: path)
            let assets = groupAssets(for: group, basePath: path)

            return AssetFolder(title: group.title, path: path, folders: folders, assets: assets)
        }

        self.init(folders)
    }
}
