//
//  TabBar.swift
//  CustomTabBar
//
//  Created by Nishant Taneja on 07/05/21.
//

import UIKit

@objc enum TabBarState: Int { case normal, options }

typealias Icon = UIView

//MARK:- DataSource
protocol TabBarDataSource: AnyObject {
    func numberOfIcons(for tabBar: TabBar) -> Int
    func tabBar(_ tabBar: TabBar, iconForItemAt index: Int, in state: TabBarState) -> Icon
}

//MARK:- Delegate
@objc protocol TabBarDelegate: AnyObject {
    @objc optional func tabBar(_ tabBar: TabBar, didSelectIconAt index: Int, in state: TabBarState)
    @objc optional func tabBar(_ tabBar: TabBar, willAnimateFrom state: TabBarState)
    @objc optional func tabBar(_ tabBar: TabBar, didAnimateTo state: TabBarState)
}

//MARK:- DelegateLayout
@objc protocol TabBarDelegateLayout: AnyObject {
    @objc optional func heightForIcon(in tabBar: TabBar) -> CGFloat
    @objc optional func paddingInTabBar(_ tabBar: TabBar) -> CGFloat
    @objc optional func iconSpacing(in tabBar: TabBar) -> CGFloat
    @objc optional func colorForShapeLayer(in tabBar: TabBar) -> CGColor
    @objc optional func iconBackgroundColor(outside tabBar: TabBar) -> UIColor
    @objc optional func iconShadowColor(outside tabBar: TabBar) -> CGColor
    @objc optional func backgroundColor(for tabBar: TabBar) -> UIColor
}

//MARK:- TabBar
class TabBar: UIView {
    // Delegates
    weak var dataSource: TabBarDataSource? {
        didSet {
            iconsCount = dataSource?.numberOfIcons(for: self) ?? iconsCount
            updateFrames()
            hide()
        }
    }
    weak var delegate: TabBarDelegate?
    weak var delegateLayout: TabBarDelegateLayout? {
        didSet {
            iconHeight = delegateLayout?.heightForIcon?(in: self) ?? iconHeight
            padding = delegateLayout?.paddingInTabBar?(self) ?? padding
            spacing = delegateLayout?.iconSpacing?(in: self) ?? spacing
            colorForIcon = delegateLayout?.iconBackgroundColor?(outside: self) ?? colorForIcon
            colorForLayer = delegateLayout?.colorForShapeLayer?(in: self) ?? colorForLayer
            color = delegateLayout?.backgroundColor?(for: self) ?? color
            shadowColorForIcon = delegateLayout?.iconShadowColor?(outside: self) ?? shadowColorForIcon
            updateFrames()
        }
    }
    
    // Constants
    private var iconsCount: Int = 5
    private var iconHeight: CGFloat = 40
    private var padding: CGFloat = 8
    private var spacing: CGFloat = 16
    private var colorForLayer: CGColor = UIColor.white.cgColor
    private var colorForIcon: UIColor = .white
    private var shadowColorForIcon: CGColor = UIColor.black.cgColor
    private var color: UIColor = .white
    
    // Properties
    private var icons = [Icon]() {
        didSet {
            framesForIcons = icons.compactMap({ $0.frame })
        }
    }
    private var framesForIcons = [CGRect]()
    private var newIcons = [Icon]()
    private var state: TabBarState = .normal
    var barState: TabBarState { state }
    private var defaultFrame: CGRect {
        let iconsCountInFloat = CGFloat(iconsCount)
        let height = iconHeight + 2*padding
        let width = iconsCountInFloat*iconHeight + 2*padding + (iconsCountInFloat - 1)*spacing
        let screenSize = UIScreen.main.bounds.size
        let originX = (screenSize.width - width)/2
        let originY = (screenSize.height - height - 16)
        return .init(x: originX, y: originY, width: width, height: height)
    }
    private func updateFrames() {
        self.frame = defaultFrame
        framesForIcons = []
        updateIcons(for: state)
    }
    
    private var shapeLayer: CAShapeLayer?
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
        path.addLine(to: .init(x: width, y: height))
        path.addLine(to: .init(x: 0, y: height))
        path.close()
        return path
    }
    private var barIsHidden: Bool = true
    var tabBarIsHidden: Bool { barIsHidden }
    
    
    // Constructors
    required init() {
        super.init(frame: .zero)
        self.frame = defaultFrame
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Layouts
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = iconHeight/2
        updateLayers()
    }
    
    // Layer
    private func updateLayers() {
        let layer = CAShapeLayer()
        layer.path = layerPath.cgPath
        layer.frame = bounds
        layer.fillColor = colorForLayer
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.shadowColor = colorForLayer
        layer.shadowOpacity = 1
        if let oldLayer = shapeLayer {
            self.layer.replaceSublayer(oldLayer, with: layer)
        } else {
            self.layer.insertSublayer(layer, at: 0)
        }
        shapeLayer = layer
    }
    
    // Icons Updation
    private func frameForIcon(at index: CGFloat) -> CGRect {
        if Int(index) < framesForIcons.count { return framesForIcons[Int(index)] }
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
            icon.tag = index
            icon.transform = .identity
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleIconTap(gesture:))))
            icon.layer.cornerRadius = iconHeight/2
            icon.layer.shadowColor = UIColor.black.cgColor
            icon.layer.shadowRadius = 5
            icon.layer.shadowOpacity = 0.5
            icon.layer.shadowOffset = .zero
            icon.frame = frameForIcon(at: CGFloat(index))
            newIcons.append(icon)
        }
        self.newIcons = newIcons
        self.newIcons.forEach({ superview?.addSubview($0) })
        icons.forEach({ $0.removeFromSuperview() })
        icons = self.newIcons
    }
    
    @objc private func handleIconTap(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        delegate?.tabBar?(self, didSelectIconAt: view.tag, in: state)
        if view.tag == Int(icons.count/2) {
            moveIcons(to: state == .normal ? .options : .normal)
        } else {
            moveIcons(to: .normal)
        }
    }
    
    // Animations
    func show() {
        self.framesForIcons = []
        alpha = 0
        frame.origin.y += frame.height + iconHeight
        icons.forEach({ $0.alpha = 0; $0.center = center })
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseIn) {
            self.alpha = 1
            self.frame.origin.y = self.defaultFrame.origin.y
            for (index, icon) in self.icons.enumerated() {
                icon.frame = self.frameForIcon(at: CGFloat(index))
                if index == Int(self.iconsCount/2) {
                    icon.frame.origin.y -= self.iconHeight
                    icon.transform = .init(scaleX: 1.2, y: 1.2)
                    icon.backgroundColor = self.colorForIcon
                }
                icon.alpha = 1
                if index < self.framesForIcons.count {
                    self.framesForIcons[index] = icon.frame
                } else {
                    self.framesForIcons.append(icon.frame)
                }
            }
        } completion: { _ in
            self.barIsHidden = false
        }
    }
    func hide() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.alpha = 0
            self.frame.origin.y += self.frame.height + self.iconHeight
            self.icons.forEach({ $0.alpha = 0; $0.center = self.center; $0.transform = .identity })
        } completion: { _ in
            self.barIsHidden = true
        }
    }
    private func moveIcons(to state: TabBarState) {
        guard state != self.state else { print("same TabBarState passed"); return }
        delegate?.tabBar?(self, willAnimateFrom: self.state)
        updateIcons(for: state)
        let midIndex = Int(iconsCount/2)
        var translationY: CGFloat = 0
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.transform = state == .normal ? .identity : .init(scaleX: 0, y: 0)
            for (index, icon) in self.icons.enumerated() {
                if index == midIndex {
                    translationY = state == .normal ? -self.iconHeight : self.iconHeight
                } else if index < midIndex {
                    let value = 0.6*CGFloat(index + 1)*self.iconHeight
                    translationY = state == .normal ? value : -value
                } else if index > midIndex {
                    let value = 0.6*CGFloat(self.iconsCount - index)*self.iconHeight
                    translationY = state == .normal ? value : -value
                    
                }
                icon.transform = .init(translationX: 0, y: translationY)
                icon.backgroundColor = state == .normal ? .clear : self.colorForIcon
                if index == midIndex {
                    icon.backgroundColor = self.colorForIcon
                } else {
                    icon.backgroundColor = state == .normal ? .clear : self.colorForIcon
                }
                self.framesForIcons[index] = icon.frame
            }
        } completion: { _ in
            self.state = state
            self.delegate?.tabBar?(self, didAnimateTo: state)
        }
    }
    func updateBarState(to state: TabBarState) {
        moveIcons(to: state)
    }
}
