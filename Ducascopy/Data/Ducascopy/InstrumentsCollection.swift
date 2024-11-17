//
//  InstrumentsCollection.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

struct InstrumentsCollection: Decodable {
    let instruments: [String: Instrumet]
    let groups: [String: AssetGroup]
}
