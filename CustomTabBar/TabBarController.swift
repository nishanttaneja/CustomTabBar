//
//  TabBarController.swift
//  CustomTabBar
//
//  Created by Nishant Taneja on 07/05/21.
//

import UIKit

class TabBarController: UIViewController, TabBarDataSource, TabBarDelegate, TabBarDelegateLayout {
    let tabBar = TabBar()
    
    // TabBar DataSource
    func numberOfIcons(for tabBar: TabBar) -> Int {
        5
    }
    
    func tabBar(_ tabBar: TabBar, iconForItemAt index: Int, in state: TabBarState) -> Icon {
        let button = UIButton(type: .system)
        var image: UIImage?
        switch index {
        case 0: image = UIImage(systemName: state == .options ? "video.fill.badge.plus" : "house.fill")
        case 1: image = UIImage(systemName: state == .options ? "arrow.up.doc.fill" : "note.text")
        case 3: image = UIImage(systemName: state == .options ? "folder.fill" : "bell.fill")
        case 4: image = UIImage(systemName: state == .options ? "folder.fill.badge.plus" : "message.fill")
        default: image = UIImage(systemName: "cross.fill")
        }
        image = image?.applyingSymbolConfiguration(.init(pointSize: 20))
        button.setImage(image, for: .normal)
        return button
    }
    
    // Delegate
    func tabBar(_ tabBar: TabBar, didSelectIconAt index: Int, in state: TabBarState) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if index == 0, let blueVC = storyboard.instantiateViewController(withIdentifier: "BlueController") as? BlueController {
            navigationController?.setViewControllers([blueVC], animated: true)
        } else if index == 1, let greenVC = storyboard.instantiateViewController(withIdentifier: "GreenController") as? GreenController {
            navigationController?.setViewControllers([greenVC], animated: true)
        } else if index == 3, let redVC = storyboard.instantiateViewController(withIdentifier: "RedController") as? RedController {
            navigationController?.setViewControllers([redVC], animated: true)
        }
    }
    
    // TabBar DelegateLayout
    func heightForIcon(in tabBar: TabBar) -> CGFloat {
        40
    }
    func paddingInTabBar(_ tabBar: TabBar) -> CGFloat {
        4
    }
    func iconSpacing(in tabBar: TabBar) -> CGFloat {
        4
    }
    
    // View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tabBar)
        tabBar.dataSource = self
        tabBar.delegate = self
        tabBar.delegateLayout = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBar.show()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBar.hide()
    }

    // Interaction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: tabBar), !tabBar.point(inside: point, with: event), tabBar.barState != .normal {
            tabBar.updateBarState(to: .normal)
        }
    }
}
