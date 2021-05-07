//
//  TabBar.swift
//  CustomTabBar
//
//  Created by Nishant Taneja on 07/05/21.
//

import UIKit

enum TabBarState { case normal, options }

typealias Icon = UIView

protocol TabBarDataSource: AnyObject {
    func numberOfIcons(for tabBar: TabBar) -> Int
    func tabBar(_ tabBar: TabBar, iconForItemAt index: Int, in state: TabBarState) -> Icon
}

class TabBar: UIView {
    // Delegates
    weak var dataSource: TabBarDataSource? {
        didSet {
            iconsCount = dataSource?.numberOfIcons(for: self) ?? iconsCount
            self.frame = defaultFrame
            updateIcons(for: state)
            loadIcons(for: state)
        }
    }
    
    //
    private var iconsCount: Int = 5
    private var icons = [Icon]()
    private var newIcons = [Icon]()
    private var state: TabBarState = .normal
    
    // Icons Updation
    private func frameForIcon(at index: CGFloat, in state: TabBarState) -> CGRect {
        let size: CGSize = .init(width: iconHeight, height: iconHeight)
        let originX = frame.origin.x + padding + index*iconHeight + index*spacing
        let originY = frame.origin.y + padding
        return .init(origin: .init(x: originX, y: originY), size: size)
    }
    private func updateIcons(for state: TabBarState) {
        guard dataSource != nil else { return }
        var newIcons = [Icon]()
        for index in 0..<iconsCount {
            let icon = dataSource!.tabBar(self, iconForItemAt: index, in: state)
            icon.backgroundColor = colorForIcon
            icon.layer.cornerRadius = iconHeight/2
            icon.frame = frameForIcon(at: CGFloat(index), in: state)
            newIcons.append(icon)
        }
        self.newIcons = newIcons
    }
    private func loadIcons(for state: TabBarState) {
        newIcons.forEach { icon in
            superview?.addSubview(icon)
        }
        icons.forEach { icon in
            icon.removeFromSuperview()
        }
        icons = newIcons
    }
    
    
    // Default Frame for TabBarState- Normal
    private var defaultFrame: CGRect {
        let iconsCountInFloat = CGFloat(iconsCount)
        let height = iconHeight + 2*padding
        let width = iconsCountInFloat*iconHeight + 2*padding + (iconsCountInFloat - 1)*spacing
        let screenSize = UIScreen.main.bounds.size
        let originX = (screenSize.width - width)/2
        let originY = (screenSize.height - height - 16)
        return .init(x: originX, y: originY, width: width, height: height)
    }
    
    // Path for Shape Layer
    private var layerPath: UIBezierPath {
        // Dependencies
        let width = frame.width
        let halfWidth = width/2
        let height = frame.height
        let halfHeight = height/2
        // Path
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: .init(x: halfWidth - height, y: 0))
        path.addCurve(to: .init(x: halfWidth, y: halfHeight), controlPoint1: .init(x: halfWidth - halfHeight, y: 0), controlPoint2: .init(x: halfWidth - halfHeight, y: halfHeight))
        path.addCurve(to: .init(x: halfWidth + height, y: 0), controlPoint1: .init(x: halfWidth + halfHeight, y: halfHeight), controlPoint2: .init(x: halfWidth + halfHeight, y: 0))
        path.addLine(to: .init(x: width, y: 0))
        return path
    }
    
    // Constants
    private let iconHeight: CGFloat = 48
    private let padding: CGFloat = 8
    private let spacing: CGFloat = 16
    private let colorForLayer: CGColor = UIColor.purple.cgColor
    private let colorForIcon: UIColor = .blue
    
    // Layers
    private var shapeLayer: CAShapeLayer?
    private func updateLayers() {
        let layer = CAShapeLayer()
        layer.path = layerPath.cgPath
        layer.frame = bounds
        layer.fillColor = colorForLayer
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.shadowColor = colorForLayer
        layer.opacity = 0.2
        if let oldLayer = shapeLayer {
            self.layer.replaceSublayer(oldLayer, with: layer)
        } else {
            self.layer.insertSublayer(layer, at: 0)
        }
        shapeLayer = layer
    }
    
    // Layouts
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .white
        layer.cornerRadius = iconHeight/2
        updateLayers()
    }
    
    // Constructors
    required init() {
        super.init(frame: .zero)
        self.frame = defaultFrame
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
