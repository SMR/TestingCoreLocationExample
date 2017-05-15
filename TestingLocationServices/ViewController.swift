//
//  ViewController.swift
//  TestingLocationServices
//
//  Created by Joe Susnick on 5/14/17.
//  Copyright © 2017 Joe Susnick. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Enable Location?",
                                          message: "We need your location to continue. Please change permission level in settings",
                                          preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
                                                print("Go to settings")
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
        
        guard CLLocationManager.locationServicesEnabled(),
            CLLocationManager.authorizationStatus() == .notDetermined else {
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        
        
    }
}

extension ViewController: CLLocationManagerDelegate {
    
}
