//
//  CTUtility.swift
//  City
//
//  Created by Midhun on 19/09/18.
//  Copyright © 2018 Midhun. All rights reserved.
//  Utility function
//

import UIKit

// MARK:- Utility
struct CTUtility
{
    
    /// Retrieves the city details from JSON File
    ///
    /// - Parameter fileName: Name of JSON file
    /// - Returns: City details array
    static func loadCityFromJSONFile(fileName : String) -> [CTCity]
    {
        if let fileData = try? getFileData(fileName: fileName), let data = fileData, let city = try? JSONDecoder().decode([CTCity].self, from: data)
        {
            return city
        }
        return [CTCity]()
    }
    
    
    /// Retrieves the file data
    ///
    /// - Parameter fileName: File name of JSON
    /// - Returns: File Data
    /// - Throws: Throws FileIO exceptions
    private static func getFileData(fileName: String) throws -> Data?
    {
        // City Data from file
        var fileData: Data?
        
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json")
        {
            // Reading data back
            do
            {
                fileData = try Data(contentsOf: fileURL)
            }
            catch
            {
                fileData = nil
                throw error
            }
        }
        else
        {
            fileData = nil
            // Throwing an exception if document directory is not reachable
            throw (NSException(name: NSExceptionName(rawValue: "Not available"), reason: "File not available", userInfo: nil) as? Error)!
        }
        return fileData
    }
}
