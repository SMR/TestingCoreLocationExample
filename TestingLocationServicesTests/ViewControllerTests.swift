//
//  ViewControllerTests.swift
//  TestingLocationServices
//
//  Created by Joe Susnick on 5/14/17.
//  Copyright © 2017 Joe Susnick. All rights reserved.
//

import XCTest
import CoreLocation
import TestableCoreLocation
import TestableUIKit
import TestSwagger

@testable import TestingLocationServices

class ViewControllerTests: XCTestCase {
    
    let viewController = ViewController()
    var locationManager: CLLocationManager!
    var requestSpy: Spy?
    var presentSpy: Spy?
    
    override func setUp() {
        super.setUp()

        viewController.loadViewIfNeeded()
        locationManager = viewController.locationManager

        requestSpy = CLLocationManager.RequestWhenInUseAuthorizationSpyController.createSpy(on: viewController.locationManager)
        requestSpy?.beginSpying()

        presentSpy = UIViewController.PresentSpyController.createSpy(on: viewController)
        presentSpy?.beginSpying()

        CLLocationManager.beginStubbingLocationServicesEnabled(with: true)
        CLLocationManager.beginStubbingAuthorizationStatus(with: .authorizedWhenInUse)
    }
    
    override func tearDown() {
        requestSpy?.endSpying()
        presentSpy?.endSpying()
        
        CLLocationManager.endStubbingLocationServicesEnabled()
        CLLocationManager.endStubbingAuthorizationStatus()
        
        super.tearDown()
    }
    
    func testViewControllerHasLocationManager() {
        XCTAssertTrue(locationManager.delegate === viewController,
                      "ViewController should have a location manager and be its delegate")
    }
    
    func testWhenInUseMessage() {
        guard let infoDictionary = Bundle(for: ViewController.self).infoDictionary,
            let whenInUsePrompt = infoDictionary["NSLocationWhenInUseUsageDescription"] as? String else {
                return XCTFail("Bundle should include a description for displaying to the user to request location when in use")
        }
        
        XCTAssertEqual(whenInUsePrompt, "please let use",
                       "Prompt should be correct")
    }
    
    // Services Disabled
    func testDoesNotRequestAuthorizationWhenLocationServicesDisabled() {
        CLLocationManager.stubbedLocationServicesEnabled = false
        viewController.viewDidAppear(false)
        
        XCTAssertFalse(locationManager.requestWhenInUseAuthorizationCalled,
                       "Should not request authorization when location services unavailable")
    }
    
    // When denied
    func testViewControllerDoesNotAskForPermissionIfAuthorizationDenied() {
        CLLocationManager.stubbedAuthorizationStatus = .denied
        viewController.viewDidAppear(false)
        
        XCTAssertFalse(viewController.locationManager.requestWhenInUseAuthorizationCalled,
                       "LocationManager should not request whenInUseAuthorization if permission denied")
    }
    
    // When restricted
    func testViewControllerDoesNotAskForPermissionIfAuthorizationRestricted() {
        CLLocationManager.stubbedAuthorizationStatus = .restricted
        viewController.viewDidAppear(false)
        
        XCTAssertFalse(viewController.locationManager.requestWhenInUseAuthorizationCalled,
                       "LocationManager should not request whenInUseAuthorization if permission restricted")
    }
    
    // When alwaysAuthorized
    func testViewControllerDoesNotAskForPermissionIfAlwaysAuthorized() {
        CLLocationManager.stubbedAuthorizationStatus = .authorizedAlways
        viewController.viewDidAppear(false)
        
        XCTAssertFalse(viewController.locationManager.requestWhenInUseAuthorizationCalled,
                       "LocationManager should not request whenInUseAuthorization if permission granted")
        
    }
    
    // When whenInUsageAuthorized
    func testViewControllerDoesNotAskForPermissionIfWhenInUseAuthorized() {
        CLLocationManager.stubbedAuthorizationStatus = .authorizedWhenInUse
        
        viewController.viewDidAppear(false)
        
        XCTAssertFalse(viewController.locationManager.requestWhenInUseAuthorizationCalled,
                       "LocationManager should not request whenInUseAuthorization if permission granted")
        
    }
    
    // When not determined
    func testViewControllerAsksForPermissionWhenViewAppearsIfNotDetermined() {
        CLLocationManager.stubbedAuthorizationStatus = .notDetermined
        viewController.viewDidAppear(false)
        
        XCTAssertTrue(viewController.locationManager.requestWhenInUseAuthorizationCalled,
                      "LocationManager should request whenInUseAuthorization when ViewController loads")
    }
    
    func testPromptsForSettingsWhenPermissionPreviouslyDenied() {
        let dummyAction = UIAlertAction()
        UIAlertAction.InitializerSpyController.createSpy(on: dummyAction)?.beginSpying()
        
        CLLocationManager.stubbedAuthorizationStatus = .denied
        viewController.viewDidAppear(false)
        
        guard viewController.presentCalled,
           let presented = viewController.presentController as? UIAlertController,
           let animated = viewController.presentAnimated,
           animated else {
            return XCTFail("ViewController should present an alertController with animation")
        }
        
        presented.actions.first?.handler?(dummyAction)
        
        XCTAssertEqual(presented.title, "Enable Location?",
                       "Title should be set correctly")
        XCTAssertEqual(presented.message, "We need your location to continue. Please change permission level in settings",
                       "Message should be set correctly")
    }
}
















