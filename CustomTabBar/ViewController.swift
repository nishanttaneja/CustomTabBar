//
//  ViewController.swift
//  CustomTabBar
//
//  Created by Nishant Taneja on 07/05/21.
//

import UIKit

class BlueController: TabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}

class GreenController: TabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }

}

class RedController: TabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }

}
