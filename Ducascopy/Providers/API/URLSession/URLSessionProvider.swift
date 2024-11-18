//
//  URLSessionProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

struct URLSessionProvider: ParametredDataProvider {
    typealias Result = (Data, HTTPResponse)
    typealias Params = HTTPRequest

    typealias ProviderError = DataProviderError

    let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetch(_ params: Params) async throws(ProviderError) -> Result {
        do {
            let (data, response) = try await urlSession.data(for: params)

            let status = response.status

            switch status.kind {
            case .invalid:
                throw ProviderError.invalid(status, data)
            case .informational, .successful, .redirection:
                break
            case .clientError:
                throw ProviderError.clientError(status, data)
            case .serverError:
                throw ProviderError.serverError(status, data)
            }

            return (data, response)

        } catch {
            throw ProviderError.anyError(error)
        }
    }
}
