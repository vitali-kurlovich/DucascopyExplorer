//
//  InstrumentDetailsViewController.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 20.11.24.
//

import UIKit
import ComposableArchitecture

final class InstrumentDetailsViewController: UICollectionViewController {
    
    private let store: StoreOf<InstrumentsFeature>
    
    init(store: StoreOf<InstrumentsFeature> = .init(initialState: .init()) {
        InstrumentsFeature()
    }) {
        self.store = store

        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
