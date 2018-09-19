//
//  CTCity.swift
//  City
//
//  Created by Midhun on 19/09/18.
//  Copyright © 2018 Midhun. All rights reserved.
//  City Model
//

import UIKit

// MARK:- City
struct CTCity: Codable
{
    // MARK: Properties
    // Id
    let id: Int
    
    // Country
    let country: String
    
    // City Name
    let name: String
    
    // Location Coordinates
    let coord: CTCoordinate
    
    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey
    {
        case id = "_id"
        case country
        case name
        case coord
    }
}

// MARK: CTCity Utility
extension CTCity
{
    /// City details
    ///
    /// - Returns: City details in the form City Name, Country
    func getCityDetail() -> String
    {
        return "\(self.name), \(self.country)"
    }
}

// MARK:- City Coordinates
struct CTCoordinate: Codable
{
    // Longitude
    let lon: Double
    
    // Latitude
    let lat: Double
}
