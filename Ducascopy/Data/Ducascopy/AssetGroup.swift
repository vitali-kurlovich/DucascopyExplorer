//
//  AssetGroup.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

/*
 "title": "0005.HK/HKD",
       "special": false,
       "name": "0005.HK/HKD",
       "description": "HSBC Holdings",
 */

struct AssetGroup: Decodable {
    let id: String
    let parent: String?

    let title: String
    let instruments: [String]?
}
