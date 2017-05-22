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
        CLLocationManager.stubbedAuthorizationStatus = .denied
        viewController.viewDidAppear(false)

        guard viewController.presentCalled,
            let alert = viewController.presentController as? UIAlertController,
            let animated = viewController.presentAnimated,
            animated else {
                return XCTFail("ViewController should present an alertController with animation")
        }

        XCTAssertNil(viewController.presentCompletion,
                     "Should not have a completion handler for presenting alert")

        XCTAssertEqual(alert.title, "Enable Location?",
                       "Title should be set correctly")
        XCTAssertEqual(alert.message, "We need your location to continue. Please change permission level in settings",
                       "Message should be set correctly")
        guard alert.actions.count == 2 else {
            return XCTFail("Alert must have two actions")
        }
    }

    func testPromptForSettingsCancelAction() {
        let dummyAction = UIAlertAction()
        let initializerSpy = UIAlertAction.InitializerSpyController.createSpy(on: dummyAction)!
        initializerSpy.beginSpying()

        CLLocationManager.stubbedAuthorizationStatus = .denied
        viewController.viewDidAppear(false)

        guard let alert = viewController.presentController as? UIAlertController else {
            return XCTFail("ViewController should present an alertController")
        }

        let cancelAction = alert.actions[0]
        XCTAssertEqual(cancelAction.style, .cancel,
                       "Cancel action should have correct style")
        XCTAssertEqual(cancelAction.title, "Cancel",
                       "Cancel action should have correct title")

        UIViewController.DismissSpyController.createSpy(on: viewController)!.spy {
            cancelAction.handler!(cancelAction)

            guard viewController.dismissCalled else {
                return XCTFail("ViewController should dismiss presented controller when alert is cancelled")
            }

            XCTAssertTrue(viewController.dismissAnimated!,
                          "ViewController should animate the dismissal of the presented controller")

            XCTAssertNil(viewController.dismissCompletion,
                         "ViewController should not have a completion handler for dismissing alert")
        }

        initializerSpy.endSpying()
    }

    func testSettingsPromptSettingsAction() {
        let dummyAction = UIAlertAction()
        let initializerSpy = UIAlertAction.InitializerSpyController.createSpy(on: dummyAction)!
        initializerSpy.beginSpying()

        CLLocationManager.stubbedAuthorizationStatus = .denied
        viewController.viewDidAppear(false)

        guard let alert = viewController.presentController as? UIAlertController else {
            return XCTFail("ViewController should present an alertController")
        }

        let settingsAction = alert.actions[1]
        XCTAssertEqual(settingsAction.style, .default,
                       "Settings action should have correct style")
        XCTAssertEqual(settingsAction.title, "Go to Settings",
                       "Settings action should have correct title")

        UIViewController.DismissSpyController.createSpy(on: viewController)!.spy {
            let application = UIApplication.shared
            UIApplication.OpenUrlSpyController.createSpy(on: application)!.spy {

                settingsAction.handler!(settingsAction)

                guard viewController.dismissCalled else {
                    return XCTFail("ViewController should dismiss presented controller when settings selected")
                }

                XCTAssertTrue(viewController.dismissAnimated!,
                              "ViewController should animate the dismissal of the presented controller")
                
                XCTAssertNil(viewController.dismissCompletion,
                             "ViewController should not have a completion handler for dismissing alert")

                guard application.openUrlCalled,
                    application.openUrlUrl == URL(string: UIApplicationOpenSettingsURLString)! else {
                    return XCTFail("Should have called openURL on shared application")
                }

                if #available(iOS 10.0, *) {

                    // test options and completion handler
                }

            }
        }
        
        initializerSpy.endSpying()
    }
}
















