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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

