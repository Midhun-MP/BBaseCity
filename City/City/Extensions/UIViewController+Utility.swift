//
//  UIViewController+Utility.swift
//  City
//
//  Created by Midhun on 19/09/18.
//  Copyright © 2018 Midhun. All rights reserved.
//  Utility functions for UIViewController
//

import UIKit

// MARK: Loading Indicator
extension UIViewController
{
    
    // Shows Loading Indicator
    func showLoading() -> UIView
    {
        var viewLoading:UIView?
        let window = UIApplication.shared.keyWindow
        
        if(viewLoading == nil)
        {
            
            viewLoading                  = UIView(frame: (window?.bounds)!)
            viewLoading?.backgroundColor = UIColor.darkGray
            viewLoading?.alpha           = 0.6
            let indicator                = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            indicator.center             = viewLoading!.center
            indicator.startAnimating()
            viewLoading?.addSubview(indicator)
        }
        
        window?.addSubview(viewLoading!)
        window?.bringSubview(toFront: viewLoading!)
        
        return viewLoading!
    }
    
    // Hide Loading
    func hideLoading(viewLoading: UIView)
    {
        viewLoading.removeFromSuperview()
    }
}
