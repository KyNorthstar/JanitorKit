//
//  File.swift
//  JanitorKit
//
//  Created by Ky on 2024-09-27.
//

import Foundation



public extension JanitorialEngine {
    
    /// Changes the configuration of this whole engine.
    ///
    /// For more granular configuraiton changes, see each individual ``SingleDirectoryJanitor``'s configurations & their ``TrackedDirectory``s
    func configure(with configuration: Configuration) async {
        await self.setDryRun(configuration.dryRun)
    }
    
    
    var currentConfig: Configuration {
        .init(dryRun: dryRun)
    }
    
    
    
    /// Config settings for the whole ``JanitorialEngine``.
    ///
    /// These fields mimic properties of a ``JanitorialEngine``. For more information on their behavior, see that documentation.
    struct Configuration: Equatable {
        public let dryRun: Bool
        
        public init(dryRun: Bool) {
            self.dryRun = dryRun
        }
        
        
        
        public static var `default`: Self {
            .init(dryRun: false)
        }
    }
}
