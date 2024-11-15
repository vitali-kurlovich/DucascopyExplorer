//
//  AssetGroup.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

struct Group: Decodable {
    let id: String
    let parent: String?

    let title: String
    let instruments: [String]?
}
