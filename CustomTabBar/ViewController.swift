//
//  ViewController.swift
//  CustomTabBar
//
//  Created by Nishant Taneja on 07/05/21.
//

import UIKit

class ViewController: UIViewController {

    private let tabBar = TabBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        view.addSubview(tabBar)
    }


}

