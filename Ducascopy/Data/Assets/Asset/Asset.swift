//
//  Asset.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

public struct Asset: Hashable {
    public let id: String

    public let path: AssetPath

    public let info: InstrumetInfo

    public init(id: String, info: InstrumetInfo, path: AssetPath) {
        self.id = id
        self.info = info
        self.path = path
    }
}

public extension Asset {
    var title: String {
        info.title
    }

    var name: String {
        info.name
    }

    var description: String {
        info.description
    }
}

extension Asset: AssetDispalyItem {
    var displayTitle: String? {
        name
    }

    var displayDetails: String? {
        description
    }
}

extension Asset {
    init(_ instrument: Instrumet, id: String, path: AssetPath) {
        let info = InstrumetInfo(instrument)

        self.init(id: id, info: info, path: path)
    }
}
