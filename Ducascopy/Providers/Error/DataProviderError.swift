//
//  DataProviderError.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 18.11.24.
//

import Foundation
import HTTPTypes

enum DataProviderError: Error {
    case anyError(any Error)
    case invalid(HTTPResponse.Status, Data)
    case clientError(HTTPResponse.Status, Data)
    case serverError(HTTPResponse.Status, Data)
    case decodingError(DecodingError)
}
