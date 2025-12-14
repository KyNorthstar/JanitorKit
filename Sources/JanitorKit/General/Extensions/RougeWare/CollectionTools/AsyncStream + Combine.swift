//
//  SwiftUIView.swift
//  JanitorKit
//
//  Created by Ky on 2025-10-28.
//

import Combine
import Foundation



public extension AsyncStream {
    /// Initializes an async stream by receiving updates from the given publisher and then transmitting them itself
    ///
    /// - Parameters:
    ///   - upstream:     Publishes updates which are transceived by this stream
    ///   - cancellables: Stores the implementation of this new async stream
    init(tranceiving upstream: AnyPublisher<Element, Never>, storeIn cancellables: inout Set<AnyCancellable>) {
        self.init { continuation in
            upstream.sink { completion in
                continuation.finish()
            }
            receiveValue: { element in
                continuation.yield(element)
            }
            .store(in: &cancellables)
        }
    }
}
