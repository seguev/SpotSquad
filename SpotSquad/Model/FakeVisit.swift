//
//  FakeVisits.swift
//  CoffeeFetch
//
//  Created by segev perets on 05/01/2023.
//

import Foundation
import CoreLocation

final class FakeVisit: CLVisit {
        
  private let myCoordinates: CLLocationCoordinate2D
  private let myArrivalDate: Date
  private let myDepartureDate: Date

  override var coordinate: CLLocationCoordinate2D {
    return myCoordinates
  }
  
  override var arrivalDate: Date {
    return myArrivalDate
  }
  
  override var departureDate: Date {
    return myDepartureDate
  }
  
  init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
    myCoordinates = coordinates
    myArrivalDate = arrivalDate
    myDepartureDate = departureDate
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private struct FakeCoordinates  {
    static var shared = FakeCoordinates()
    lazy var cafeArray = [henrietaCafe,streetsCafe,easyCafe,kioskoCafe,dedeCafe]
    let henrietaCafe : CLLocationCoordinate2D = .init(latitude: 32.08314546974592, longitude: 34.79179908605931)
    let streetsCafe : CLLocationCoordinate2D = .init(latitude: 32.0851453157972, longitude: 34.78190709916755)
    let easyCafe : CLLocationCoordinate2D = .init(latitude: 32.05630358519695, longitude: 34.77084923941069)
    let kioskoCafe : CLLocationCoordinate2D = .init(latitude: 32.05738427890526, longitude: 34.769743806385684)
    let dedeCafe : CLLocationCoordinate2D = .init(latitude: 32.05754215235314, longitude: 34.7695150441779)
}

    /**
        Makes an [FakeVisit] array that function like [CLVisit] for dibugging .
     */
   func makeDebugFakeVisitsArray (_ n:Int) -> [FakeVisit] {
    var array = [FakeVisit]()
    
    for _ in 0..<n {
        let randomCoordinateFromCafe : CLLocationCoordinate2D = FakeCoordinates.shared.cafeArray.randomElement()!
        
        let randomTimeInterval = TimeInterval(Int.random(in: (-1000)...(-100)))
        
        let newFakeVisit = FakeVisit(coordinates: randomCoordinateFromCafe, arrivalDate: Date().addingTimeInterval(randomTimeInterval), departureDate: Date().addingTimeInterval(randomTimeInterval))
        
        array.append(newFakeVisit)
    }
    
    return array
}


