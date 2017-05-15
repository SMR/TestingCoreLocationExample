//
//  OpenURLSpy.swift
//  TestingLocationServices
//
//  Created by Joe Susnick on 5/14/17.
//  Copyright © 2017 Joe Susnick. All rights reserved.
//

import TestSwagger
import FoundationSwagger

extension UIApplication {
    
    private static let openUrlCalledString = UUIDKeyString()
    private static let openUrlCalledKey = ObjectAssociationKey(openUrlCalledString)
    private static let openUrlCalledReference = SpyEvidenceReference(key: openUrlCalledKey)
    
    private static let openUrlUrlString = UUIDKeyString()
    private static let openUrlUrlKey = ObjectAssociationKey(openUrlUrlString)
    private static let openUrlUrlReference = SpyEvidenceReference(key: openUrlUrlKey)
    
    private static let openUrlOptionsString = UUIDKeyString()
    private static let openUrlOptionsKey = ObjectAssociationKey(openUrlOptionsString)
    private static let openUrlOptionsReference = SpyEvidenceReference(key: openUrlOptionsKey)
    
    private static let openUrlCompletionString = UUIDKeyString()
    private static let openUrlCompletionKey = ObjectAssociationKey(openUrlCompletionString)
    private static let openUrlCompletionReference = SpyEvidenceReference(key: openUrlCompletionKey)
    
    
    /// Spy controller for ensuring an instance of `UIApplication` has had `openUrl(_:)` or
    /// `open(_:options:completionHandler:)` called on it.
    public enum OpenUrlSpyController: SpyController {
        public static let rootSpyableClass: AnyClass = UIApplication.self
        public static let vector = SpyVector.direct
        public static let forwardsInvocations = false
        
        public static let coselectors: Set<SpyCoselectors> = {
            let coselectors: SpyCoselectors
            if #available(iOS 10.0, *) {
                coselectors = SpyCoselectors(
                    methodType: .instance,
                    original: #selector(UIApplication.open(_:options:completionHandler:)),
                    spy: #selector(UIApplication.spy_open(_:options:completionHandler:))
                )
            }
            else {
                coselectors = SpyCoselectors(
                    methodType: .instance,
                    original: #selector(UIApplication.openURL(_:)),
                    spy: #selector(UIApplication.spy_openUrl(_:))
                )
            }
            
            return [coselectors] as Set
        }()
        
        public static let evidence = [
            openUrlCalledReference,
            openUrlUrlReference,
            openUrlOptionsReference,
            openUrlCompletionReference
            ] as Set
    }
    
    
    /// Spy method that replaces the true implementation of `openUrl(_:)`
    func spy_openUrl(_ url: URL) {
        openUrlCalled = true
        openUrlUrl = url
    }
    
    
    /// Spy method that replaces the true implementation of `open(_:options:completionHandler:)`
    func spy_open(
        _ url: URL,
        options: [String: Any],
        completionHandler: ((Bool) -> Void)?
        ) {
        
        openUrlCalled = true
        openUrlUrl = url
        openUrlOptions = options
        openUrlCompletion = completionHandler
    }
    
    
    /// Indicates whether the `openUrl(_:)` or `open(_:options:completionHandler:)` method
    /// has been called on this object.
    final var openUrlCalled: Bool {
        get {
            return loadEvidence(with: UIApplication.openUrlCalledReference) as? Bool ?? false
        }
        set {
            saveEvidence(true, with: UIApplication.openUrlCalledReference)
        }
    }
    
    
    /// Provides the URL passed to `openUrl(_:)` or `open(_:options:completionHandler:)`, if called.
    final var openUrlUrl: URL? {
        get {
            return loadEvidence(with: UIApplication.openUrlUrlReference) as? URL
        }
        set {
            let reference = UIApplication.openUrlUrlReference
            guard let url = newValue else {
                return removeEvidence(with: reference)
            }
            
            saveEvidence(url, with: reference)
        }
    }
    
    
    /// Provides the options dictionary passed to `open(_:options:completionHandler:)`, if called.
    final var openUrlOptions: [String: Any]? {
        get {
            return loadEvidence(with: UIApplication.openUrlOptionsReference) as? [String: Any]
        }
        set {
            let reference = UIApplication.openUrlOptionsReference
            guard let options = newValue else {
                return removeEvidence(with: reference)
            }
            
            saveEvidence(options, with: reference)
        }
    }
    
    
    /// Provides the completion handler passed to `open(_:options:completionHandler:)`, if called.
    final var openUrlCompletion: ((Bool) -> Void)? {
        get {
            return loadEvidence(with: UIApplication.openUrlCompletionReference) as? (Bool) -> Void
        }
        set {
            let reference = UIApplication.openUrlCompletionReference
            guard let handler = newValue else {
                return removeEvidence(with: reference)
            }
            
            saveEvidence(handler, with: reference)
        }
    }
    
}
