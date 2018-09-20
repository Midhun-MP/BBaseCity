//
//  CTDetailViewController.swift
//  City
//
//  Created by Midhun on 20/09/18.
//  Copyright © 2018 Midhun. All rights reserved.
//  Represents the detail VC

import UIKit
import MapKit

// MARK:- IBOutlet
class CTDetailViewController: UIViewController
{
    
    /// Map to show coordinates
    @IBOutlet weak var mkMapView: MKMapView!
    
    // City Details
    var city: CTCity!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = city.getCityDetail()
        loadMap()
    }
    
    // Shows the data in Map
    private func loadMap()
    {
        let latitude  = CLLocationDegrees(exactly: city.coord.lat)
        let longitude = CLLocationDegrees(exactly: city.coord.lon)
        let center    = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let region    = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mkMapView.setRegion(region, animated: true)
        
        addAnnotation(atCoordinate: center)
    }
    
    /// Add location pin
    ///
    /// - Parameter coordinate: Coordinate point
    private func addAnnotation(atCoordinate coordinate: CLLocationCoordinate2D)
    {
        let annotation        = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mkMapView.addAnnotation(annotation)
    }
}
