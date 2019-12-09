//
//  ICASegmentedControl.swift
//  iOSConsumerApp
//
//  Created by Wahyu Sumartha on 06/01/2017.
//  Copyright © 2017 iCarAsia. All rights reserved.
//

import UIKit

protocol ICASegmentedControlHeader: class {
  var sectionTitles: [String] { get }
  var indicatorHeight: CGFloat { get }
  var segmentWidth: CGFloat { get }
  var borderWidth: CGFloat { get }
  var dividerWidth: CGFloat { get }
}

protocol ICASegmentedControlAppearance: class {
  var titleFont: UIFont { get }
  var titleColor: UIColor { get }
  var selectedTitleFont: UIFont { get }
  var selectedTitleColor: UIColor { get }
  var indicatorColor: UIColor { get }
  var shadowColor: UIColor { get }
  var borderColor: UIColor { get }
  var dividerColor: UIColor { get }
}

protocol ICASegmentedControlBehaviour: class {
  var selectedIndex: Int { get set }
  var isDraggable: Bool { get }
}

extension ICASegmentedControlBehaviour {
  func setSelectedSegment(at index: Int) {
    selectedIndex = index
  }
}

public class ICASegmentedControl: UIControl, ICASegmentedControlBehaviour, ICASegmentedControlHeader, ICASegmentedControlAppearance {
  public var scrollView: ICAScrollView?
 
  public var selectedIndex: Int = 0
  public var isDraggable: Bool = false
 
  public var sectionTitles: [String] = []
  public var indicatorHeight: CGFloat = 2
  public var segmentWidth: CGFloat = 100
  public var borderWidth: CGFloat = 1
  public var dividerWidth: CGFloat = 1
 
  public var titleFont: UIFont = UIFont.systemFont(ofSize: 14)
  public var titleColor: UIColor = UIColor.blue
  public var selectedTitleFont: UIFont = UIFont.systemFont(ofSize: 14)
  public var selectedTitleColor: UIColor = UIColor.red
  public var indicatorColor: UIColor = UIColor.red
  public var shadowColor: UIColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1.0)
  public var borderColor: UIColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
  public var dividerColor: UIColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
  
  let selectedIndicatorLayer = CALayer()

  public var isShowBorder = false
  public var isShowVerticalDivider = false
  public var isShadowEnable = false
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    initializeComponent()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeComponent()
  }

  init(sectionTitles: [String]) {
    super.init(frame: .zero)
    self.sectionTitles = sectionTitles
    initializeComponent()
  }
  
  func setSelectedSegment(at index: Int, animated: Bool) {
    setSelectedSegment(at: index, animated: animated, notify: true)
  }
  
  private func setSelectedSegment(at index: Int, animated: Bool, notify: Bool) {
    setSelectedSegment(at: index)
    setNeedsDisplay()
    
    // handle for no selected index
    if index < 0 {
      selectedIndicatorLayer.removeFromSuperlayer()
    } else {
      scrollToSelectedSegment(animated: animated)
      
      if animated {
        if selectedIndicatorLayer.superlayer == nil {
          scrollView?.layer.addSublayer(selectedIndicatorLayer)
          setSelectedSegment(at: index, animated: false, notify: true)
        }
        
        if notify { notifySegmentChanged(to: index) }
        
        // restore CALayer Animation 
        selectedIndicatorLayer.actions = nil
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.15)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear))
        selectedIndicatorLayer.frame = frameSelectionIndicator()
        CATransaction.commit()
      } else {
        // disable CALayer animation
        let actions = ["position": NSNull(),
                       "bounds": NSNull()]
        
        selectedIndicatorLayer.actions = actions
        selectedIndicatorLayer.frame = frameSelectionIndicator()
        
        if notify { notifySegmentChanged(to: index) }
      }
    }
  }
  
  private func notifySegmentChanged(to index: Int) {
    if (self.superview != nil) {
      sendActions(for: .valueChanged)
    }
  }
  
  private func scrollToSelectedSegment(animated isAnimated: Bool) {
    let rectForSelectedIndex = CGRect(x: segmentWidth * CGFloat(selectedIndex),
                                  y: 0,
                                  width: segmentWidth,
                                  height: frame.size.height)
    let selectedSegmentOffset = (frame.size.width/2) - (segmentWidth/2)
    
    var rectScrollTo = rectForSelectedIndex
    rectScrollTo.origin.x -= selectedSegmentOffset
    rectScrollTo.size.width += selectedSegmentOffset * 2
    scrollView?.scrollRectToVisible(rectScrollTo, animated: isAnimated)
  }

  //MARK: Initialize the component
  private func initializeComponent() {
    scrollView = ICAScrollView()
    scrollView?.scrollsToTop = false
    scrollView?.showsVerticalScrollIndicator = false
    scrollView?.showsHorizontalScrollIndicator = false
    scrollView?.backgroundColor = UIColor.white
    addSubview(scrollView!)

    // apply shadow
    if isShadowEnable {
      layer.shadowColor = shadowColor.cgColor
      layer.masksToBounds = false
      layer.shadowOffset = CGSize(width: 0, height: 1.0)
      layer.shadowOpacity = 1
      layer.shadowRadius = 1
    } else {
      let borderLayer = CALayer()
      borderLayer.backgroundColor = borderColor.cgColor
      borderLayer.frame = CGRect(x: 0,
                                 y: frame.size.height - borderWidth,
                                 width: frame.size.width,
                                 height: borderWidth)
      layer.addSublayer(borderLayer)
    }
    
    backgroundColor = UIColor.red
    contentMode = .redraw
  }
  
  //MARK: Frame and layout Handler 
  override public func layoutSubviews() {
    super.layoutSubviews()
    updateSegmentRects()
  }
  
  override public var frame: CGRect {
    get {
      return super.frame
    }
    set {
      super.frame = newValue
      updateSegmentRects()
    }
  }
  
  func updateSegmentRects() {
    scrollView?.contentInset = .zero
    scrollView?.frame = CGRect(x: 0, y: 0,
                               width: frame.width, height: frame.height)
   
    if sectionCount() > 0 {
      segmentWidth = frame.size.width / CGFloat(sectionCount())
    }
    
    scrollView?.isScrollEnabled = isDraggable
    scrollView?.contentSize = CGSize(width: segmentWidth * CGFloat(sectionCount()),
                                     height: frame.height)
  }
  
  //MARK: Draw Box 
  override public func draw(_ rect: CGRect) {
    backgroundColor?.setFill()
    UIRectFill(bounds)
    
    selectedIndicatorLayer.backgroundColor = indicatorColor.cgColor
    
    scrollView?.layer.sublayers = nil
    
    for (index, _) in sectionTitles.enumerated() {
      let size = titleSize(at: index)
      let stringHeight = size.height
      
      var segmentRect = CGRect(x: segmentWidth * CGFloat(index),
                        y: (frame.height-stringHeight)/2,
                        width: segmentWidth,
                        height: stringHeight)
      let rectDivider = CGRect(x: (segmentWidth * CGFloat(index)) - dividerWidth,
                               y: 0,
                               width: dividerWidth,
                               height: rect.size.height)

//      let rectDivider = CGRect(x: 30,
//                               y: 0,
//                               width: dividerWidth,
//                               height: rect.size.height)

      
      //fix rect position
      segmentRect = CGRect(x: CGFloat(ceilf(Float(segmentRect.origin.x))),
                    y: CGFloat(ceilf(Float(segmentRect.origin.y))),
                    width: CGFloat(ceilf(Float(segmentRect.size.width))),
                    height: CGFloat(ceilf(Float(segmentRect.size.height))))
    
      if isShowVerticalDivider {
        let verticalDividerLayer = CALayer()
        verticalDividerLayer.frame = rectDivider
        verticalDividerLayer.backgroundColor = dividerColor.cgColor
        scrollView?.layer.addSublayer(verticalDividerLayer)
      }
      
      let titleLayer = CATextLayer()
      titleLayer.frame = segmentRect
      titleLayer.string = titleAttributes(at: index)
      titleLayer.font = titleFont.fontName as CFTypeRef?
      titleLayer.fontSize = titleFont.pointSize
      titleLayer.foregroundColor = titleColor.cgColor
        titleLayer.alignmentMode = CATextLayerAlignmentMode.center
      titleLayer.backgroundColor = UIColor.clear.cgColor
      titleLayer.contentsScale = UIScreen.main.scale
      scrollView?.layer.addSublayer(titleLayer)
      
    }
    
    if selectedIndicatorLayer.superlayer == nil {
      selectedIndicatorLayer.frame = frameSelectionIndicator()
      scrollView?.layer.addSublayer(selectedIndicatorLayer)
    }
    
    addBorderLayer(with: rect)
  }
 
  //MARK: Text Content 
  func titleSize(at index: Int) -> CGSize {
    if index >= sectionTitles.count { return .zero }
   
    let title = sectionTitles[index]
    let selected = (index == selectedIndex) ? true : false
    let titleAttributes = selected ? selectedTitleAttributes() : titleTextAttributes()
    let size = (title as NSString).size(withAttributes: titleAttributes)
    return size
  }
  
  //MARK: Data Source
  private func sectionCount() -> Int {
    return sectionTitles.count
  }
  
  public func setSectionTitles(sectionTitles: [String]) {
    self.sectionTitles = sectionTitles
    setNeedsLayout()
    setNeedsDisplay()
  }
  
  //MARK: Text Styling
    func selectedTitleAttributes() -> [NSAttributedString.Key: Any] {
    let defaults = [NSAttributedString.Key.font: selectedTitleFont,
        NSAttributedString.Key.foregroundColor: selectedTitleColor] as [NSAttributedString.Key : Any]
    return defaults
  }
  
    func titleTextAttributes() -> [NSAttributedString.Key: Any] {
    let defaults = [NSAttributedString.Key.font: titleFont,
                    NSAttributedString.Key.foregroundColor: titleColor] as [NSAttributedString.Key : Any]
    return defaults
  }
  
  func titleAttributes(at index: Int) -> NSAttributedString {
    let title = sectionTitles[index]
    let selected = (index == selectedIndex) ? true : false
    
    var titleAttrs = selected ? selectedTitleAttributes() : titleTextAttributes()
    
    if let titleColor = titleAttrs[NSAttributedString.Key.foregroundColor] {
      var dictTitleAttr = titleAttrs
      dictTitleAttr[NSAttributedString.Key.foregroundColor] = (titleColor as! UIColor).cgColor
      titleAttrs = dictTitleAttr
      return NSAttributedString(string: title, attributes: titleAttrs)
    } else {
      return NSAttributedString(string: title)
    }
  }
  
  //MARK: Indicator Styling 
  fileprivate func frameSelectionIndicator() -> CGRect {
    let yOffset = bounds.size.height - indicatorHeight
    return CGRect(x: segmentWidth * CGFloat(selectedIndex),
               y: yOffset,
               width: segmentWidth,
               height: indicatorHeight)
  }
  
  //MARK: Adding Border 
  func addBorderLayer(with rect: CGRect) {
    if isShowBorder {
      let backgroundLayer = CALayer()
      backgroundLayer.frame = rect
      scrollView?.layer.insertSublayer(backgroundLayer, at: 0)
      
      // top border
      let topBorderLayer = CALayer()
      topBorderLayer.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: borderWidth)
      topBorderLayer.backgroundColor = borderColor.cgColor
      backgroundLayer.addSublayer(topBorderLayer)
      
      // left border
//      let leftBorderLayer = CALayer()
//      leftBorderLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: rect.size.height)
//      leftBorderLayer.backgroundColor = borderColor.cgColor
//      backgroundLayer.addSublayer(leftBorderLayer)
    
      // bottom border
      let bottomBorderLayer = CALayer()
      bottomBorderLayer.frame = CGRect(x: 0, y: rect.size.height - borderWidth, width: rect.size.width, height: borderWidth)
      bottomBorderLayer.backgroundColor = borderColor.cgColor
      backgroundLayer.addSublayer(bottomBorderLayer)
      
      // right border
//      let rightBorderLayer = CALayer()
//      rightBorderLayer.frame = CGRect(x: rect.size.width - borderWidth, y: 0, width: borderWidth, height: rect.size.height)
//      rightBorderLayer.backgroundColor = borderColor.cgColor
//      backgroundLayer.addSublayer(rightBorderLayer)
    }
  }
  
  //MARK: Touch 
  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first
    if let touchLocation = touch?.location(in: self) {
      if bounds.contains(touchLocation) {
        let segment = (touchLocation.x + (scrollView?.contentOffset.x)!) / segmentWidth
        
        if Int(segment) != selectedIndex && Int(segment) < sectionTitles.count {
          setSelectedSegment(at: Int(segment), animated: true, notify: true)
        }
      }
    }
  }
  
}
