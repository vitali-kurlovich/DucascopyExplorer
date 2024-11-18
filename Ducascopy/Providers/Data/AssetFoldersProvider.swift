//
//  AssetFoldersProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 18.11.24.
//

struct AssetFoldersProvider<Provider: DataProvider>: DataProvider
    where Provider.Result == InstrumentsCollection,
    Provider.ProviderError == DataProviderError
{
    typealias Result = [AssetFolder]
    typealias ProviderError = DataProviderError

    let provider: Provider

    init(_ provider: Provider) {
        self.provider = provider
    }

    func fetch() async throws(ProviderError) -> Result {
        let collection = try await provider.fetch()
        return [AssetFolder](collection)
    }
}
