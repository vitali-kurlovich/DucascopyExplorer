//
//  DataProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

protocol DataProvider<Result, ProviderError> {
    associatedtype Result
    associatedtype ProviderError: Error

    func fetch() async throws(ProviderError) -> Result
}

protocol ParametredDataProvider {
    associatedtype Params
    associatedtype Result
    associatedtype ProviderError: Error

    func fetch(_ params: Params) async throws(ProviderError) -> Result
}
