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
    private var cityDetails: [String: [CTCity]]?
    
    // Section Titles
    private var sectionTitles: [String]?
    
    // Selected City
    private var selectedCity: CTCity!
    
    // Filtered result
    var filteredCities: [CTCity]?
    
    // Search Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    var dateForLog:Date!
    
    // City Info
    var cityData: [CTCity]?
    
    // Search timer to handle fast typing
    var searchTimer: Timer!
    
    // Stores previous search text length (For incremental search)
    var previousSearchTextLength = 0
    
    // View Did Load
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadCityDetails()
        configureSearchBar()
    }
    
    // Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == CTConstants.goToDetailSegue
        {
            let destination   = segue.destination as? CTDetailViewController
            destination?.city = selectedCity
        }
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
            numOfSections = cityData?.count ?? 0
        }
        
        // If section count is greater, hiding the no data background
        // Else adding the no data background
        if numOfSections > 0
        {
            numOfSections = 1
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
            cities = cityData
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
            city = cityData![indexPath.row]
        }
        cell.lblCityDetail.text = "\(city.name), \(city.country)"
        return cell
    }
    
    // Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isFiltering()
        {
            selectedCity = filteredCities![indexPath.row]
        }
        else
        {
            let cities   = cityDetails![sectionTitles![indexPath.section]]
            selectedCity = cities![indexPath.row]
        }
        self.performSegue(withIdentifier: CTConstants.goToDetailSegue, sender: nil)
    }
}


// MARK: - UISearchResultsUpdating
extension CTMainViewController: UISearchResultsUpdating, UISearchControllerDelegate
{
    // MARK:- UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController)
    {
        if searchController.searchBar.text!.count > 0
        {
            tblCityList.dataSource = nil
            tblCityList.delegate   = nil
            if searchTimer != nil && searchTimer.isValid
            {
                searchTimer.invalidate()
            }
            
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
                self.filterContentForSearchText(searchController.searchBar.text!)
            })
        }
    }
    
    // Search Cancel
    func didDismissSearchController(_ searchController: UISearchController)
    {
        tblCityList.dataSource = self
        tblCityList.delegate   = self
    }
    
    func searchBarIsEmpty() -> Bool
    {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    /// Data filtering function
    ///
    /// - Parameter searchText: String need to be searched
    @objc func filterContentForSearchText(_ searchText: String)
    {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            if self.previousSearchTextLength == 0 || self.previousSearchTextLength >= searchText.count
            {
                let cities          = self.cityData?.filter { (city) -> Bool in city.getCityDetail().lowercased().hasPrefix(searchText.lowercased())
                }
                self.filteredCities = cities
            }
            else
            {
                self.filteredCities = self.filteredCities?.filter({ (city) -> Bool in city.getCityDetail().lowercased().hasPrefix(searchText.lowercased())
                })
            }
            self.previousSearchTextLength = searchText.count
            
            DispatchQueue.main.async {
                print(self.filteredCities?.count ?? 0)
                self.tblCityList.dataSource = self
                self.tblCityList.delegate   = self
                self.tblCityList.reloadData()
            }
        }
        
    }
}

// MARK:- Utility
extension CTMainViewController
{
    
    /// Configures the search bar
    func configureSearchBar()
    {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater      = self
        searchController.searchBar.placeholder     = "Search Cities"
        searchController.searchBar.tintColor       = UIColor.white
        searchController.searchBar.barStyle        = .black
        navigationItem.searchController            = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext                 = true
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
        dateForLog = Date()
        let view = self.showLoading()
        DispatchQueue.global().async {
            var cities         = CTUtility.loadCityFromJSONFile(fileName: CTConstants.fileName)
            print("For reading \(Date().offsetFrom(date: self.dateForLog))")
            self.dateForLog = Date()
            self.cityDetails   = [String: [CTCity]]()
            self.sectionTitles = [String]()
            //cities             = self.sortCity(cities: cities)
            self.cityData      = self.sortCity(cities: cities)
            print("For Sorting \(Date().offsetFrom(date: self.dateForLog))")
//            self.dateForLog = Date()
//            self.configureDataModel(cities: cities)
//            print("For Data Model \(Date().offsetFrom(date: self.dateForLog))")
//            self.dateForLog = Date()
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

extension Date {
    
    func offsetFrom(date : Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + " " + seconds
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
    
}
