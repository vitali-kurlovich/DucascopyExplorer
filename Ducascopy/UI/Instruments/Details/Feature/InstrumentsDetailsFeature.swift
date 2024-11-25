//
//  InstrumentsDetailsFeature.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 24.11.24.
//

import ComposableArchitecture

@Reducer
struct InstrumentsDetailsFeature {
    @ObservableState
    struct State: Equatable {
        var displayState: DisplayState = .none
    }

    enum DisplayState: Equatable {
        case none
        case inProgress
        case error(String)
    }

    enum Action {
        case willAppear
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .willAppear:
                return .none
            }
        }
    }
}
