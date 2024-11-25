//
//  InstrumentsCollectionProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import DataProvider
import Foundation
import HTTPTypes

struct InstrumentsCollectionProvider<RequestProvider: HTTPRequestProvider>: DataProvider {
    typealias Result = InstrumentsCollection
    typealias ProviderError = DataProviderError

    let requestProvider: RequestProvider
    let urlSession: URLSession

    init(_ requestProvider: RequestProvider, urlSession: URLSession = .shared) {
        self.requestProvider = requestProvider
        self.urlSession = urlSession
    }

    func fetch() async throws(ProviderError) -> Result {
        let sessionProvider = URLSessionProvider(urlSession: urlSession)
        
        let dataProvider = sessionProvider.map { data, _ -> Data in
            data.dropFirst("jsonp(".count).dropLast(")".count)
        }.decode(InstrumentsCollection.self)

        let request = requestProvider.request()

        return try await dataProvider.fetch(request)
    }
}
