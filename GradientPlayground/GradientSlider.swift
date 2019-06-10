//
//  GradientSlider.swift
//  GradientPlayground
//
//  Created by Roland Tolnay on 04/06/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit

class GradientSlider: UIView {

  static let maxValue: Double = 100
  static let minValue: Double = 0

  var onValueChanged: ((_ value: Double) -> Void)?

  @IBInspectable
  var value: Double = 100 {
    didSet {
      value = value.clamped(to: GradientSlider.minValue...GradientSlider.maxValue)
      setNeedsDisplay()
    }
  }

  @IBInspectable
  var startColor: UIColor = #colorLiteral(red: 1, green: 0.8235294118, blue: 0.137254902, alpha: 1) {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable
  var endColor: UIColor = #colorLiteral(red: 1, green: 0.1960784314, blue: 0.7450980392, alpha: 1) {
    didSet {
      setNeedsDisplay()
    }
  }

  @IBInspectable
  var shadowColor: UIColor = #colorLiteral(red: 1, green: 0.2901960784, blue: 0.1960784314, alpha: 1) {
    didSet {
      setNeedsDisplay()
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }

  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    setup()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    setNeedsDisplay()
  }

  var backgroundPath = UIBezierPath()
  var gradientPath = UIBezierPath()

  private func setup() {

    clearsContextBeforeDrawing = true
    clipsToBounds = false
    backgroundColor = .clear
    isExclusiveTouch = true
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    guard let context = UIGraphicsGetCurrentContext(),
      let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                colors: [startColor.cgColor, endColor.cgColor] as CFArray,
                                locations: [0.0, 1.0])
      else { return }

    let cornerRadius = rect.height / 2
    let levelNormalizedWidth = CGFloat((value / GradientSlider.maxValue)) * rect.width

    gradientPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
    backgroundPath = UIBezierPath(roundedRect: rect.offsetBy(dx: levelNormalizedWidth,
                                                             dy: 0),
                                  byRoundingCorners: [.topRight, .bottomRight],
                                  cornerRadii: CGSize(width: cornerRadius,
                                                      height: cornerRadius))
    backgroundPath.close()

    context.saveGState()

    gradientPath.addClip()
    context.drawLinearGradient(gradient,
                               start: CGPoint.zero,
                               end: CGPoint(x: rect.width, y: 0),
                               options: [])
    #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1).setFill()
    backgroundPath.fill()

    context.restoreGState()

    layer.shadowColor = shadowColor.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 8.0)
    layer.shadowRadius = 12.0
    layer.shadowOpacity = 0.3
    layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero,
                                                        size: CGSize(width: levelNormalizedWidth,
                                                                     height: rect.height)),
                                    cornerRadius: cornerRadius).cgPath
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    update(with: touches)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    update(with: touches)
  }

  private func update(with touches: Set<UITouch>) {

    guard let firstTouch = touches.first else { return }
    let point = firstTouch.location(in: self)
    value = GradientSlider.maxValue * Double(point.x/bounds.width)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    onValueChanged?(value)
  }
}

extension Comparable {

  public func clamped(to limits: ClosedRange<Self>) -> Self {

    return min(max(self, limits.lowerBound), limits.upperBound)
  }
}
