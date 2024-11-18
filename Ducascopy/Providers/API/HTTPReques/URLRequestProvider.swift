//
//  URLRequestProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 19.11.24.
//

import Foundation
import HTTPTypes

struct URLRequestProvider: HTTPRequestProvider {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func request() -> HTTPRequest {
        let privider = BaseHTTPRequestProvider(url)
        return privider.request()
    }
}
