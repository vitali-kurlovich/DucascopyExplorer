//
//  MapParametredDataProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

public struct MapParametredDataProvider<Provider: ParametredDataProvider, Result>: ParametredDataProvider {
    public typealias Params = Provider.Params
    public typealias ProviderError = Provider.ProviderError

    let provider: Provider
    let convertResult: (Provider.Result) -> Result

    public init(provider: Provider, convertResult: @escaping (Provider.Result) -> Result) {
        self.provider = provider
        self.convertResult = convertResult
    }

    public func fetch(_ params: Provider.Params) async throws(ProviderError) -> Result {
        let result = try await provider.fetch(params)
        return convertResult(result)
    }
}

public extension ParametredDataProvider {
    func map<TargetResult>(_ convertResult: @escaping (Self.Result) -> TargetResult) -> MapParametredDataProvider<Self, TargetResult> {
        .init(provider: self, convertResult: convertResult)
    }
}
