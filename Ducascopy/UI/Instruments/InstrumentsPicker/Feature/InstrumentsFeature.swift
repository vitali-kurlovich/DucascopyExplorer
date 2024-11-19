//
//  InstrumentsFeature.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 19.11.24.
//

import ComposableArchitecture

@Reducer
struct InstrumentsFeature {
    @ObservableState
    struct State: Equatable {
        var loading: LoadingState = .none
    }

    enum LoadingState: Equatable {
        case none
        case inProgress
        case error(String)
        case ready([AssetFolder])
    }

    enum Action {
        case willAppear
        case fetchFolders
        case recieveFolders([AssetFolder])
        case recieveError(String)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .willAppear:

                switch state.loading {
                case .ready, .inProgress:
                    return .none
                default:
                    break
                }

                return .run { send in
                    await send(.fetchFolders)
                }

            case .fetchFolders:
                state.loading = .inProgress
                return .run { send in
                    do {
                        let folders = try await Providers.assetFoldersProvider.fetch()
                        await send(.recieveFolders(folders))
                    } catch {
                        await send(.recieveError(error.localizedDescription))
                    }
                }

            case let .recieveFolders(folders):
                state.loading = .ready(folders)
                return .none

            case let .recieveError(description):
                state.loading = .error(description)
                return .none
            }
        }
    }
}
