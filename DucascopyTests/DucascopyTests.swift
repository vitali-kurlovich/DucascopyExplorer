//
//  DucascopyTests.swift
//  DucascopyTests
//
//  Created by Vitali Kurlovich on 14.11.24.
//

@testable import Ducascopy
import Testing

struct DucascopyTests {
    @Test func assetFolders() async throws {
        let collection = InstrumentsCollection.testCollection

        let folders = [AssetFolder](collection)
        print(folders.count)
    }
}

extension InstrumentsCollection {
    static var testCollection: InstrumentsCollection {
        let groups: [String: AssetGroup] = [
            "A": AssetGroup(id: "A", parent: nil, title: "A Group", instruments: []),
            "B": AssetGroup(id: "B", parent: nil, title: "B Group", instruments: ["EUR/USD"]),
            "C": AssetGroup(id: "C", parent: "A", title: "C Group", instruments: ["OIL", "WTR"]),
            "D": AssetGroup(id: "D", parent: "C", title: "D Group", instruments: ["APPL", "MST"]),
        ]

        let instruments: [String: Instrumet] = [
            "EUR/USD": Instrumet(title: "EUR/USD", name: "EUR/USD", description: "Euro USD"),
            "OIL": Instrumet(title: "OIL", name: "OIL", description: "Oil"),
            "WTR": Instrumet(title: "WTR", name: "WTR", description: "Water"),
            "APPL": Instrumet(title: "APPL", name: "APPL", description: "Apple Inc"),
            "MST": Instrumet(title: "MST", name: "MST", description: "Microsoft Inc"),
        ]

        return InstrumentsCollection(instruments: instruments, groups: groups)
    }
}
