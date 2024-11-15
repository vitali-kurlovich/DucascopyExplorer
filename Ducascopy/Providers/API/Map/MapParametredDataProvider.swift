//
//  MapParametredDataProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

struct MapParametredDataProvider<Provider: ParametredDataProvider, Result>: ParametredDataProvider {
    typealias Params = Provider.Params
    typealias ProviderError = Provider.ProviderError

    let provider: Provider
    let convertResult: (Provider.Result) -> Result

    init(provider: Provider, convertResult: @escaping (Provider.Result) -> Result) {
        self.provider = provider
        self.convertResult = convertResult
    }

    func fetch(_ params: Provider.Params) async throws(Provider.ProviderError) -> Result {
        let result = try await provider.fetch(params)
        return convertResult(result)
    }
}

extension ParametredDataProvider {
    func map<TargetResult>(_ convertResult: @escaping (Self.Result) -> TargetResult) -> MapParametredDataProvider<Self, TargetResult> {
        .init(provider: self, convertResult: convertResult)
    }
}
