//
//  InstrumentsHTTPRequestProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import Foundation
import HTTPTypes

struct InstrumentsCollectionProvider<RequestProvider: HTTPRequestProvider>: DataProvider {
    typealias Result = InstrumentsCollection

    enum ProviderError: Error {
        case anyError(any Error)
        case invalid(HTTPResponse.Status, Data)
        case clientError(HTTPResponse.Status, Data)
        case serverError(HTTPResponse.Status, Data)
        case decodingError(DecodingError)
    }

    let requestProvider: RequestProvider
    let urlSession: URLSession

    init(_ requestProvider: RequestProvider, urlSession: URLSession = .shared) {
        self.requestProvider = requestProvider
        self.urlSession = urlSession
    }

    func fetch() async throws(ProviderError) -> InstrumentsCollection {
        let sessionProvider = URLSessionProvider(urlSession: urlSession)

        let dataProvider = sessionProvider.map { data, _ -> Data in
            data.dropFirst("jsonp(".count).dropLast(")".count)
        }.decode(InstrumentsCollection.self)

        do {
            return try await dataProvider.fetch(requestProvider.request())
        } catch {
            switch error {
            case let .anyError(result):
                throw .anyError(result)
            case let .dataProviderError(result):
                switch result {
                case let .anyError(anyError):
                    throw .anyError(anyError)
                case let .invalid(status, data):
                    throw .invalid(status, data)
                case let .clientError(status, data):
                    throw .clientError(status, data)
                case let .serverError(status, data):
                    throw .serverError(status, data)
                }
            case let .decodingError(result):
                throw .decodingError(result)
            }
        }
    }
}
