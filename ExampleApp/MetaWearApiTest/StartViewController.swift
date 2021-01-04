//
//  StartViewController.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 11/2/16.
//  Copyright © 2016 MbientLab. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: animated)
    }
    
}
