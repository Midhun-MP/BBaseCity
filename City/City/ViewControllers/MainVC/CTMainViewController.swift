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
    private var cityDetails: [CTCity]?
    
    // Section Titles
    private var sectionTitles: [String]?
    
    // Selected City
    private var selectedCity: CTCity!
    
    // Filtered result
    var filteredCities: [CTCity]?
    
    // Search Controller
    let searchController = UISearchController(searchResultsController: nil)
    
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
            numOfSections = cityDetails?.count ?? 0
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
            cities = cityDetails
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
            city = cityDetails![indexPath.row]
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
            selectedCity   = cityDetails![indexPath.row]
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
        tblCityList.reloadData()
    }
    
    // Search Bar empty check
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
            
            // If previous search is there, using it's output
            // Else starting a fresh search
            if self.previousSearchTextLength == 0 || self.previousSearchTextLength >= searchText.count
            {
                let cities          = self.cityDetails?.filter { (city) -> Bool in city.getCityDetail().lowercased().hasPrefix(searchText.lowercased())
                }
                self.filteredCities = cities
            }
            else
            {
                self.filteredCities = self.filteredCities?.filter({ (city) -> Bool in city.getCityDetail().lowercased().hasPrefix(searchText.lowercased())
                })
            }
            self.previousSearchTextLength = searchText.count
            
            // Updating UI
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
        let view = self.showLoading()
        DispatchQueue.global().async {
            let cities         = CTUtility.loadCityFromJSONFile(fileName: CTConstants.fileName)
            self.cityDetails   = self.sortCity(cities: cities)
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
}
