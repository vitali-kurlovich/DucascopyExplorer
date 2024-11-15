//
//  BaseHTTPRequestProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

import Foundation
import HTTPTypes

struct BaseHTTPRequestProvider: HTTPRequestProvider {
    let baseURL: URL
    let method: HTTPRequest.Method
    let headerFields: HTTPFields

    init(_ baseURL: URL, method: HTTPRequest.Method = .get, headerFields: HTTPFields = [:]) {
        self.baseURL = baseURL
        self.method = method
        self.headerFields = headerFields
    }

    func request() -> HTTPRequest {
        var headerFields = self.headerFields

        if !headerFields.contains(.referer) {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
            components?.query = nil

            if let value = components?.string, !value.isEmpty {
                let field = HTTPField(name: .referer, value: value)
                headerFields.append(field)
            }
        }

        return HTTPRequest(method: method, url: baseURL, headerFields: headerFields)
    }
}
