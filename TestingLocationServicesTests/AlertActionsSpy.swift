//
//  AlertActionsSpy.swift
//  TestingLocationServices
//
//  Created by Joe Susnick on 5/14/17.
//  Copyright © 2017 Joe Susnick. All rights reserved.
//

import TestableUIKit
import TestSwagger
import FoundationSwagger

typealias UIAlertActionHandler = (UIAlertAction) -> Void

extension UIAlertAction: ObjectSpyable {
    
    private static let handlerString = UUIDKeyString()
    private static let handlerKey = ObjectAssociationKey(handlerString)
    private static let handlerReference = SpyEvidenceReference(key: handlerKey)
    
    
    /// Spy controller for manipulating the initialization of an alert action.
    enum InitializerSpyController: SpyController {
        public static let rootSpyableClass: AnyClass = UIAlertAction.self
        public static let vector = SpyVector.direct
        public static let coselectors = [
            SpyCoselectors(
                methodType: .class,
                original: NSSelectorFromString("actionWithTitle:style:handler:"),
                spy: #selector(UIAlertAction.spy_action(title:style:handler:))
            )
            ] as Set
        public static let evidence = Set<SpyEvidenceReference>()
        public static let forwardsInvocations = true
    }
    
    
    /// Spy method that replaces the true implementation of `init(title:style:handler:)`
    dynamic class func spy_action(
        title: String?,
        style: UIAlertActionStyle,
        handler: UIAlertActionHandler?
        ) -> UIAlertAction {
        
        let action = spy_action(title: title, style: style, handler: handler)
        action.handler = handler
        return action
    }
    
    
    /// Provides the handler pass to `init(title:style:handler:)` if available.
    final var handler: UIAlertActionHandler? {
        get {
            return loadEvidence(with: UIAlertAction.handlerReference) as? UIAlertActionHandler
        }
        set {
            let reference = UIAlertAction.handlerReference
            guard let newHandler = newValue else {
                return removeEvidence(with: reference)
            }

            saveEvidence(newHandler, with: reference)
        }
    }
    
}
