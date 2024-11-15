//
//  JsonDecodindProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import Foundation

struct JsonDecodingProvider<Params, Result: Decodable, Provider: ParametredDataProvider>: ParametredDataProvider
    where Provider.Params == Params, Provider.Result == Data
{
    enum ProviderError: Error {
        case anyError(any Error)
        case dataProviderError(Provider.ProviderError)
        case decodingError(DecodingError)
    }

    let decoder: JSONDecoder
    let provider: Provider

    init(_: Result.Type, decoder: JSONDecoder = JSONDecoder(), provider: Provider) {
        self.decoder = decoder
        self.provider = provider
    }

    func fetch(_ params: Params) async throws(ProviderError) -> Result {
        do {
            let data = try await provider.fetch(params)

            return try decoder.decode(Result.self, from: data)
        } catch {
            if let error = error as? Provider.ProviderError {
                throw ProviderError.dataProviderError(error)
            }

            if let error = error as? DecodingError {
                throw ProviderError.decodingError(error)
            }

            throw ProviderError.anyError(error)
        }
    }
}

extension ParametredDataProvider where Self.Result == Data {
    func decode<Object: Decodable>(_ type: Object.Type, decoder: JSONDecoder = JSONDecoder()) -> JsonDecodingProvider<Self.Params, Object, Self> {
        .init(type, decoder: decoder, provider: self)
    }
}
