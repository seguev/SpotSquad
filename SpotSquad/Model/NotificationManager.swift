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

        let df = DateFormatter()
        df.dateFormat = "YYYY, HH:mm a"
        let arrival = df.string(from: visit.arrivalDate)
        
        let isDistantFuture = visit.departureDate == Date.distantFuture
        let departure = isDistantFuture ? "NoDipartureTime" : df.string(from: visit.departureDate)
        
        let visitInterval = visit.departureDate.timeIntervalSince(visit.arrivalDate)
        let spentTime = isDistantFuture ? "Unknown timeframe" : turnTimeIntervalToString(visitInterval)
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        if let placeName = mapItem?.placemark.name {
            content.title = "You were at \(placeName) ☕️ for \(spentTime)."
            content.body = "From \(arrival) To \(departure). R=\(visit.horizontalAccuracy)"
        } else {
            content.title = "You just stopped somewhere for \(spentTime)."
            content.body = "Not a Cafe"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(60), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
                
    private func turnTimeIntervalToString (_ timeInterval:TimeInterval) -> String {
        if timeInterval > 3600 {
            return "\(timeInterval/120)h"
        } else if timeInterval < 3600 && timeInterval > 60 {
            return "\(timeInterval/60)m"
        } else {
            return "\(timeInterval)s"
        }
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
