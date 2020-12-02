//
//  CollectionsViewModel.swift
//  PinterestClone
//
//  Created by SonHoang on 12/2/20.
//

import Foundation
import Combine

class CollectionsViewModel: ViewModelType {
    
    struct Input {
        let loadCollections: AnyPublisher<Void, Never>
        let showDetailCollection: AnyPublisher<Int, Never>
    }
    
    enum Action {
        case loadCollections
        case loadedCollections([ImageCollection])
        case showDetailCollection(Int)
    }
    
    struct State {
        var collections: [ImageCollection] = []
        var detailToShow: Int? = nil
    }
    
    struct Output {
        let collections: AnyPublisher<[ImageCollection], Never>
        let showDetail: AnyPublisher<Int, Never>
    }
    
    func transform(environment: Environment) -> (Input) -> Output {
        
        let request = requestCollections(environment: environment)
        
        return { input in
            let store = Store<Action, State, Environment>(initial: State(), environment: environment) { (state, action, environment) -> AnyPublisher<Action, Never> in
                switch action {
                case .loadCollections:
                    return request
                case .loadedCollections(let collections):
                    state.collections = collections
                    state.detailToShow = nil
                case .showDetailCollection(let detailToShow):
                    state.detailToShow = detailToShow
                }
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            
            let action = Publishers.Merge(input.loadCollections.map { Action.loadCollections },
                                          input.showDetailCollection.map { Action.showDetailCollection($0) })
            
            action.subscribe(store)
            
            return Output(collections: store.state.map { $0.collections }.eraseToAnyPublisher(),
                          showDetail: store.state.compactMap { $0.detailToShow }.eraseToAnyPublisher())
        }
    }
    
}

private func requestCollections(environment: Environment) -> AnyPublisher<CollectionsViewModel.Action, Never> {
    return Empty(completeImmediately: false).map { CollectionsViewModel.Action.loadedCollections([]) }.eraseToAnyPublisher()
}
