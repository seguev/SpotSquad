//
//  NotificationManager.swift
//  CoffeeFetch
//
//  Created by segev perets on 05/01/2023.
//

import Foundation
import UserNotifications
import CoreLocation
import MapKit

let foundPlaceNotificationName = Notification.Name("foundNewPlace")

struct NotificationManager {
    
    static let shared = NotificationManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    /**
     "Were you at \(placeName) ?? it's nice place!"
     */
    func sendSpecificNotification (_ mapItem:MKMapItem?, visit:CLVisit) {
        let spendTime = Int(visit.departureDate.timeIntervalSince(visit.arrivalDate) / 60)
        #warning("if more than X min, dont log visit .")

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = "New visit registered!"
        if let placeName = mapItem?.placemark.name {
            content.body = "You at \(placeName) ☕️ for \(spendTime) minutes"
        } else {
            content.body = "You just stopped somewhere for \(spendTime) min. not a cafe though."
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(60), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request)
        
        print("new notification added at \(Date().addingTimeInterval(TimeInterval(1)))")
    }
    
    func coreDataUpdate (_ info:String) {
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = "Core data update 👨🏻‍💻"
        content.body = info
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(60), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request)
        
        
    }
    
}
