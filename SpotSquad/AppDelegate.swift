//
//  AppDelegate.swift
//  SpotSquad
//
//  Created by segev perets on 05/01/2023.
//

import UIKit
import CoreLocation
import UserNotifications
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import MapKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        locationManager.delegate = self
        
        NotificationManager.shared.notificationCenter.requestAuthorization(options: [.alert,.badge,.sound]) { _, _ in}
        return true
    }

    // MARK: - Location Delegate funcs
    
   
        
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        handleUserLocation(status: manager.authorizationStatus)
    }
    
    /**
     Checks if use location CLAuthorizationStatus and call delegate.gotLocationAndCanProceed if so.
     */
    private func handleUserLocation (status: CLAuthorizationStatus) {
            
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startMonitoringVisits()
        default:
            redirectToSettings()
        }
    }
    
    private func redirectToSettings () {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
 
    
    /**
    - calls request on each visit and if its a new cafe, save it.
     - when login, Do Not launch a new request for every visits saved, just uplaod from core data!
     */
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {        
        Task {
             let newSpot = await checkIfVisitedCafe(visit.coordinate)
                
                NotificationManager.shared.sendSpecificNotification(newSpot, visit: visit)
                
                StorageManager.shared.checkIfExistsAndProceed(newSpot)
        }
    }
    
    /**
     Being called from the background
     */
    private func checkIfVisitedCafe (_ coorditanes:CLLocationCoordinate2D) async -> MKMapItem?  {
        print("making a request!")
        let request = MKLocalPointsOfInterestRequest(center: coorditanes, radius: 100)
        
        request.pointOfInterestFilter = .init(including: [.cafe])
        
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            let itemsWithName = response.mapItems.filter {$0.name != nil}
            return itemsWithName[0]
        } catch {
            print(error)
            return nil
        }
        
    }
    
    
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    // MARK: - CoreData stack
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "SpotSquad")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return container
        }()
    

}

