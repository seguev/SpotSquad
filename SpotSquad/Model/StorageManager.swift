//
//  StorageManager.swift
//  CoffeeFetch
//
//  Created by segev perets on 06/01/2023.
//

import UIKit
import CoreData
import CoreLocation
import MapKit

struct StorageManager {
    
    static let shared = StorageManager()
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    private func fechAllSpots () -> [Spot] {
        let request : NSFetchRequest<Spot> = .init(entityName: "Spot")
        do {
            return try context.fetch(request)
        } catch {
            print(error)
            return []
        }
    }
    
    func printAllSavesSpots () {
        let spots = fechAllSpots()
        print("* Saved spots so far")
        for spot in spots {
            print("\(spot.name!) : \(spot.visits)")
        }
        print("______________")
    }
    


    /**
     Create NSFetchRequests with name predicate.
     - if spot already exists, update its visits value to += 1
     - if not, saves a new Spot on core data.
     */
    func checkIfExistsAndProceed (_ item:MKMapItem?) {
        guard let item = item else {return}
        
        let itemsName = item.placemark.name!

        let request : NSFetchRequest<Spot> = .init(entityName: "Spot")
        
        request.predicate = NSPredicate(format: "name MATCHES[cd] %@", itemsName)
        
        var matchingSpots = [Spot]()
        do {
            matchingSpots = try context.fetch(request)
        } catch {print(error)}
        
        let exists  = !matchingSpots.isEmpty
        
        if exists {
            updateExistingSpot(matchingSpots[0])
        } else if !exists {
            saveNewSpot(item)
        }
    }
    
    
    private func saveNewSpot (_ item:MKMapItem) {

            let newSpot = Spot(context: context)
            newSpot.name = item.placemark.name
            newSpot.address = item.placemark.thoroughfare
            newSpot.visits = 1
            try! context.save()
            NotificationManager.shared.coreDataUpdate("New spot! \(newSpot.name!)")
        print("New spot! \(newSpot.name!)")
    }
    
    private func updateExistingSpot (_ existingSpot:Spot) {
     
            existingSpot.visits += 1
            try! context.save()
            NotificationManager.shared.coreDataUpdate("Its your #\(existingSpot.visits) visit at \(existingSpot.name!)")
    }

    /**
     - Fech all saved spots from core data
     - Updates delegate?.spotsArray
     - Call updateUI notification
     */
     func loadSortedSpotsStrings () -> [String] {
         let allSpots = fechAllSpots()
        
         let sortedSpotArray = allSpots.sorted { $0.visits > $1.visits }
         
         let stringedArray = sortedSpotArray.map { $0.name! }
         
         return stringedArray
         

     }
    
    /**
     Creates 10 fake visits from random Cafe coordinates and saves it in core data as spots.
     */
    func saveTenFakeVisits () async {
        let visits = makeDebugFakeVisitsArray(10) as [CLVisit]
        for visit in visits {
            let coordinate = visit.coordinate
            let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: 100)
            let search = MKLocalSearch(request: request)
            let result = try? await search.start()
             let item = result?.mapItems[0]
            checkIfExistsAndProceed(item)
        }
    }
    
    
//    func deleteAllVisits () {
//        do {
//            let allSavedVisits = try context.fetch(NSFetchRequest<Visit>(entityName: "Visit"))
//            print("found \(allSavedVisits.count) saved visits")
//
//
//            for i in 0..<allSavedVisits.count {
//                print("\(i). deleting object")
//                context.delete(allSavedVisits[i])
//            }
//            try context.save()
//            print("Now you have \(allSavedVisits.count) Visists saved")
//        } catch {
//            print(error)
//        }
//    }
    
//    func deleteFirstNumVisits (_ n:Int) {
//        print(#function)
//        do {
//            let allSavedVisits = try context.fetch(NSFetchRequest<Visit>(entityName: "Visit"))
//            print("found \(allSavedVisits.count) saved visits")
//
//
//            for i in 0..<allSavedVisits.count - n {
//                print("\(i). deleting object")
//                context.delete(allSavedVisits[i])
//            }
//            try context.save()
//            print("Now you have \(allSavedVisits.count - n) Visists saved")
//        } catch {
//            print(error)
//        }
//    }
    
//    func deleteSpot (_ filterName:String?) {
//
//        let request = NSFetchRequest<Visit>(entityName: "Visit")
//        if let filter = filterName {
//            let predicate = NSPredicate(format: "name MATCHES[cd] %@", filter)
//            request.predicate = predicate
//        }
//        do {
//            let item = try context.fetch(request)
//            for i in item {
//                context.delete(i)
//            }
//            try context.save()
//        } catch {
//            print(#function)
//            print(error)
//        }
//    }
    
    
}
