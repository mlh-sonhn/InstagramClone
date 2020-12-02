//
//  Store.swift
//  PinterestClone
//
//  Created by SonHoang on 12/2/20.
//

import Foundation
import Combine

final class Store<Action, State, Environment>: Subscriber {
    let state: AnyPublisher<State, Never>
    
    init(initial: State, environment: Environment, reducer: @escaping (inout State, Action, Environment) -> AnyPublisher<Action, Never>) {
        state = action.scan(initial) { [lock, action, cancellables] in
            var state = $0
            var cancellables = cancellables
            reducer(&state, $1, environment).sink {
                lock.lock()
                action.send($0)
                lock.unlock()
            }.store(in: &cancellables)
            return state
        }.share()
        .eraseToAnyPublisher()
    }
    
    deinit {
        lock.lock()
        action.send(completion: .finished)
        lock.unlock()
    }

    private let action = PassthroughSubject<Action, Never>()
    private let lock = NSRecursiveLock()
    private let cancellables = Set<AnyCancellable>()
    
}

extension Store {
    
    typealias Input = Action
    
    typealias Failure = Never
    
    func receive(_ input: Action) -> Subscribers.Demand {
        lock.lock()
        action.send(input)
        lock.unlock()
        return .none
    }
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
    }
    
}
