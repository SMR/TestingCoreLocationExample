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
                self.dismiss(animated: true)

                guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
                    fatalError()
                }

                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.dismiss(animated: true)
            }
            alert.addAction(cancelAction)
            alert.addAction(settingsAction)
            
            present(alert, animated: true)
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
