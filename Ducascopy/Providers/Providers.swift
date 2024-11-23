//
//  Providers.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

import DataProvider
import Foundation
import HTTPTypes

enum Providers {}

extension Providers {
    typealias InstrumentsProvider = InstrumentsCollectionProvider<URLRequestProvider>

    static var instrumentsCollectionProvider: InstrumentsProvider {
        InstrumentsProvider(.init(url: .ducascopyURL))
    }
}

extension Providers {
    typealias AssetsFoldersProvider = AssetFoldersProvider<InstrumentsProvider>

    static var assetFoldersProvider: AssetsFoldersProvider {
        AssetsFoldersProvider(instrumentsCollectionProvider)
    }
}

private extension URL {
    static var ducascopyURL: URL {
        URL(string: "https://freeserv.dukascopy.com/2.0/index.php?path=common%2Finstruments&json")!
    }
}
