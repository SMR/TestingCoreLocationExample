//
//  AuthorizationStubHelper.swift
//  TestingLocationServices
//
//  Created by Joe Susnick on 5/14/17.
//  Copyright © 2017 Joe Susnick. All rights reserved.
//

import CoreLocation
import TestSwagger
import FoundationSwagger

extension CLLocationManager {
    
    private static let authorizationStatusSurrogateString = UUIDKeyString()
    private static let authorizationStatusSurrogateKey =
        ObjectAssociationKey(authorizationStatusSurrogateString)
    
    private class var authorizationStatusSurrogate: MethodSurrogate? {
        get {
            return association(for: authorizationStatusSurrogateKey) as? MethodSurrogate
        }
        set {
            guard let surrogate = newValue else {
                return removeAssociation(for: authorizationStatusSurrogateKey)
            }
            
            associate(surrogate, with: authorizationStatusSurrogateKey)
        }
    }
    
    class func beginStubbingAuthorizationStatus(with status: CLAuthorizationStatus) {
        
        guard authorizationStatusSurrogate == nil else { return }
        
        stubbedAuthorizationStatus = status
        
        let surrogate = MethodSurrogate(
            forClass: CLLocationManager.self,
            ofType: .class,
            originalSelector: #selector(CLLocationManager.authorizationStatus),
            alternateSelector: #selector(CLLocationManager.stub_authorizationStatus)
        )
        
        surrogate.useAlternateImplementation()
        authorizationStatusSurrogate = surrogate
    }
    
    class func endStubbingAuthorizationStatus() {
        authorizationStatusSurrogate?.useOriginalImplementation()
        authorizationStatusSurrogate = nil
        stubbedAuthorizationStatus = nil
    }
    
    dynamic class func stub_authorizationStatus() -> CLAuthorizationStatus {
        return stubbedAuthorizationStatus ?? stub_authorizationStatus()
    }
    
    private static let stubbedAuthorizationStatusString = UUIDKeyString()
    private static let stubbedAuthorizationStatusKey =
        ObjectAssociationKey(stubbedAuthorizationStatusString)
    
    class var stubbedAuthorizationStatus: CLAuthorizationStatus? {
        get {
            let status = association(for: stubbedAuthorizationStatusKey)
            return status as? CLAuthorizationStatus
        }
        set {
            guard let status = newValue else {
                return removeAssociation(for: stubbedAuthorizationStatusKey)
            }
            
            associate(status, with: stubbedAuthorizationStatusKey)
        }
    }
    
}
