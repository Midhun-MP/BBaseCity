//
//  CTMainViewController.swift
//  City
//
//  Created by Midhun on 19/09/18.
//  Copyright © 2018 Midhun. All rights reserved.
//  Represents the main view controller of the application
//

import UIKit

// MARK:- IBOutlets & Properties
class CTMainViewController: UIViewController
{
    // City List Tableview
    @IBOutlet weak var tblCityList: UITableView!
    
    // City details
    var cityDetails: [String: [CTCity]]?
    
    // Section Titles
    fileprivate var sectionTitles: [String]?
    
    // Filtered result
    var filteredCities: [CTCity]?
    
    // Search Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    // View Did Load
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadCityDetails()
        configureSearchBar()
    }

}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension CTMainViewController: UITableViewDataSource, UITableViewDelegate
{
    // No.of Sections
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        
        // Finding the section count
        if isFiltering()
        {
            numOfSections = filteredCities?.count ?? 0
        }
        else
        {
            numOfSections = sectionTitles?.count ?? 0
        }
        
        // If section count is greater, hiding the no data background
        // Else adding the no data background
        if numOfSections > 0
        {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    // No.of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var cities: [CTCity]?
        if isFiltering()
        {
            cities = filteredCities
        }
        else
        {
            cities = cityDetails![sectionTitles![section]]
        }
        return cities?.count ?? 0
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: CTConstants.cellIdentifier) as! CTCityTableViewCell
        
        var city: CTCity
        if isFiltering()
        {
            city = filteredCities![indexPath.row]
        }
        else
        {
            city = cityDetails![sectionTitles![indexPath.section]]![indexPath.row]
        }
        cell.lblCityDetail.text = "\(city.name), \(city.country)"
        return cell
    }
}


// MARK: - UISearchResultsUpdating
extension CTMainViewController: UISearchResultsUpdating
{
    // MARK:- UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool
    {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")
    {
        let firstCharacter = searchText.first ?? Character(" ")
        let firstLetter    = String(firstCharacter).uppercased()
        let cities         = cityDetails![firstLetter]
        filteredCities = cities?.filter { (city) -> Bool in
            city.getCityDetail().lowercased().hasPrefix(searchText.lowercased())
        }
        tblCityList.reloadData()
    }
}

// MARK:- Utility
extension CTMainViewController
{
    
    /// Configures the search bar
    func configureSearchBar()
    {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Cities"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    
    // Search is active or not
    func isFiltering() -> Bool
    {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
}

// MARK:- Data Loading
extension CTMainViewController
{
    
    /// Loads the city details
    func loadCityDetails()
    {
        let view = self.showLoading()
        DispatchQueue.global().async {
            var cities         = CTUtility.loadCityFromJSONFile(fileName: CTConstants.fileName)
            self.cityDetails   = [String: [CTCity]]()
            self.sectionTitles = [String]()
            cities             = self.sortCity(cities: cities)
            self.configureDataModel(cities: cities)
            DispatchQueue.main.async {
                self.hideLoading(viewLoading: view)
                self.tblCityList.dataSource = self
                self.tblCityList.delegate   = self
                self.tblCityList.reloadData()
            }
        }
    }
    
    
    /// Sorts the city in albhabetical order (City first, Country then)
    ///
    /// - Parameter cities: City array
    /// - Returns: Sorted City array
    private func sortCity(cities: [CTCity]) -> [CTCity]
    {
        return cities.sorted(by:{ (first, second) -> Bool in
            first.getCityDetail() < second.getCityDetail()
        })
    }
    
    
    /// Configures the data model
    ///
    /// - Parameter cities: Cities List
    private func configureDataModel(cities: [CTCity])
    {
        for city in cities
        {
            if let firstCharacter = city.name.first
            {
                // Creating the index title
                let firstLetter  = String(firstCharacter).uppercased()
                
                // Storing city in corresponding section
                var cityArray = self.cityDetails![firstLetter] ?? [CTCity]()
                cityArray.append(city)
                self.cityDetails![firstLetter] = cityArray
                
                // Storing the section title
                if !self.sectionTitles!.contains(firstLetter)
                {
                    self.sectionTitles?.append(firstLetter)
                }
            }
        }
    }
    
}

