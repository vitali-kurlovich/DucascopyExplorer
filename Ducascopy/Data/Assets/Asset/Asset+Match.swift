//
//  Asset+Match.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 17.11.24.
//

extension Asset {
    func match(by search: String) -> Bool {
        title.range(of: search, options: [.caseInsensitive]) != nil ||
            description.range(of: search, options: [.caseInsensitive]) != nil
    }
}

extension Sequence where Element == Asset {
    func match(by searchString: String) -> [Asset] {
        let search = searchString.trimmingCharacters(in: .whitespacesAndNewlines)

        if search.isEmpty {
            return []
        }

        return filter { asset in
            asset.match(by: search)
        }
    }
}
