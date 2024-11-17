//
//  Asset.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

public struct Asset: Hashable {
    public let id: String
    public let title: String
    public let name: String
    public let description: String
    public let path: AssetPath

    public init(id: String, title: String, name: String, description: String, path: AssetPath) {
        self.id = id
        self.title = title
        self.name = name
        self.description = description
        self.path = path
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
        let title = instrument.title
        let name = instrument.name
        let description = instrument.description

        self.init(id: id, title: title, name: name, description: description, path: path)
    }
}
