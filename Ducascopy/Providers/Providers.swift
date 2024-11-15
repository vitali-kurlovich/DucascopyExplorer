//
//  Providers.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

import Foundation
import HTTPTypes

struct Providers {
    
    static var instrumentsCollectionProvider:InstrumentsCollectionProvider<DucascopyRequestProvider> {
        InstrumentsCollectionProvider(.init())
    }
    
}


struct DucascopyRequestProvider: HTTPRequestProvider {
        
    func request() -> HTTPRequest {
       let privider = BaseHTTPRequestProvider(.ducascopyURL)
        return privider.request()
    }

}

extension URL {
    
    fileprivate static var ducascopyURL: URL {
        URL(string:"https://freeserv.dukascopy.com/2.0/index.php?path=common%2Finstruments&json")!
    }
}

