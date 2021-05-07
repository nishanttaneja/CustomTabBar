//
//  ViewController.swift
//  CustomTabBar
//
//  Created by Nishant Taneja on 07/05/21.
//

import UIKit

class ViewController: UIViewController, TabBarDataSource {
    private let tabBar = TabBar()
    
    func numberOfIcons(for tabBar: TabBar) -> Int {
        3
    }
    
    func tabBar(_ tabBar: TabBar, iconForItemAt index: Int, in state: TabBarState) -> Icon {
        let icon = Icon()
        
        return icon
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        view.addSubview(tabBar)
        tabBar.dataSource = self
    }


}

