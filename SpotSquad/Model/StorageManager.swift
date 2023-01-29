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
    
    func printAllSavesSpots () {
        let request : NSFetchRequest<Spot> = .init(entityName: "Spot")
        do {
            let spots = try context.fetch(request)
            print("* Saved spots so far :")
            for spot in spots {
                print("\(spot.name!) : \(spot.visits)")
            }
            print("______________")
        } catch {
            print(error)
        }
    }
    
    private func fechAllSpots () -> [Spot] {
        let request : NSFetchRequest<Spot> = .init(entityName: "Spot")
        do {
            return try context.fetch(request)
        } catch {
            print(error)
            return []
        }
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
        
        let exists  = matchingSpots.count > 0
        
        if exists {
            updateExistingSpot(matchingSpots[0])
        } else if !exists {
            saveNewSpot(item)
        }
        
    }
    
    
    private func saveNewSpot (_ item:MKMapItem) {
        
        do {
            let newSpot = Spot(context: context)
            newSpot.name = item.placemark.name
            newSpot.address = item.placemark.thoroughfare
            newSpot.visits = 0
            try context.save()
            NotificationManager.shared.coreDataUpdate("New spot! \(newSpot.name!)")
        } catch {
            print(#function)
            print(error)
        }
    }
    
    private func updateExistingSpot (_ existingSpot:Spot) {
     
        do {
            existingSpot.visits += 1
            try context.save()
            NotificationManager.shared.coreDataUpdate("Its your #\(existingSpot.visits) visit at \(existingSpot.name!)")
        } catch {
            print(error)
        }
        
    }

    /**
     - Fech all saved spots from core data
     - Filter top 3 (if exists)
     - Updates delegate?.spotsArray
     - Call updateUI notification
     */
     func loadMostVisitedSpots () -> [String] {
         let allSpots = fechAllSpots()
        
         let sortedSpotArray = allSpots.sorted { $0.visits > $1.visits }
         
         if sortedSpotArray.count > 2 {
             let topThree = Array(sortedSpotArray[0...2])
             
             let topThreeStringed = topThree.map {$0.name!}
             
             return topThreeStringed
             
         } else {
             let stringedArray = sortedSpotArray.map{$0.name!}
             
             return stringedArray
         }
    }
    
    
    
    /*
     func updateSpotVisits(coordinate: CLLocationCoordinate2D, managedObjectContext: NSManagedObjectContext) {
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Spot")
         let predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", coordinate.latitude, coordinate.longitude)
         fetchRequest.predicate = predicate
         do {
             let spots = try managedObjectContext.fetch(fetchRequest) as! [Spot]
             if spots.count > 0 {
                 // spot exists, update visits
                 let spot = spots[0]
                 spot.visits += 1
             } else {
                 // spot does not exist, create new spot and set visits
                 let spot = NSEntityDescription.insertNewObject(forEntityName: "Spot", into: managedObjectContext) as! Spot
                 spot.latitude = coordinate.latitude
                 spot.longitude = coordinate.longitude
                 spot.visits = 1
             }
             try managedObjectContext.save()
         } catch {
             print("Error fetching or saving data: \(error)")
         }
     }

     
     */
    
    
    
    
    
    
//    func loadVisits () -> [Visit] {
//
//        let request = NSFetchRequest<Visit>(entityName: "Visit")
//
//        do {
//            return try context.fetch(request)
//        } catch {
//            print(#function)
//            print(error)
//
//        }
//        return []
//    }
    
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
