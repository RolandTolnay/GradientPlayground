//
//  GradientSlider.swift
//  GradientPlayground
//
//  Created by Roland Tolnay on 10/06/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class GradientSlider: UIControl {
	
	static let maxValue: Double = 1
	static let minValue: Double = 0
	
  /// Called every time the value changes
  var onValueChanged: ((_ value: Double) -> Void)?
  /// Called once the user finishes moving the slider
  var onValueSubmitted: ((_ value: Double) -> Void)?
	
	@IBInspectable
	var value: Double = 50 {
		didSet {
			value = value.clamped(to: GradientSlider.minValue...GradientSlider.maxValue)
      updateLayout(for: value)
		}
	}
	
	@IBInspectable
	var startColor: UIColor = #colorLiteral(red: 1, green: 0.1960784314, blue: 0.7450980392, alpha: 1) {
		didSet { setup() }
	}
	
	@IBInspectable
	var endColor: UIColor = #colorLiteral(red: 1, green: 0.8235294118, blue: 0.137254902, alpha: 1) {
		didSet { setup() }
	}

  @IBInspectable
  var thumbDiameter: CGFloat = 30.0 {
    didSet { setup() }
  }

  private let sliderHeight: CGFloat = 2.0
	
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
    setup()
  }

  private var isHoldingThumb = false

	private let filledSliderLayer = CAGradientLayer()
  private let thumbView = UIView()
  private let emptySliderView = UIView()


	private func setup() {

    updateLayout(for: value)

    setup(filledSliderLayer: filledSliderLayer)
		layer.addSublayer(filledSliderLayer)

    setup(emptySliderView: emptySliderView)
    addSubview(emptySliderView)

    setup(thumbView: thumbView)
    addSubview(thumbView)

    bringSubviewToFront(thumbView)
	}

  private func updateLayout(for value: Double) {

    let valueNormalizedWidth = CGFloat((value / GradientSlider.maxValue)) * frame.width
    thumbView.frame = CGRect(x: (valueNormalizedWidth - thumbDiameter / 2).clamped(to: 0...frame.width - thumbDiameter),
                             y: frame.height / 2 - thumbDiameter / 2 + sliderHeight / 2,
                             width: thumbDiameter,
                             height: thumbDiameter)
    emptySliderView.frame = CGRect(x: valueNormalizedWidth,
                                   y: frame.height / 2,
                                   width: frame.width,
                                   height: sliderHeight)
  }

  private func setup(filledSliderLayer: CAGradientLayer) {

    filledSliderLayer.frame = CGRect(x: 0, y: frame.height / 2, width: frame.width, height: sliderHeight)
    filledSliderLayer.colors = [startColor.cgColor, endColor.cgColor]
    filledSliderLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    filledSliderLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    addShadow(to: filledSliderLayer)
  }

  private func setup(thumbView: UIView) {

    thumbView.layer.cornerRadius = thumbView.frame.height / 2

    let thumbGradientLayer = CAGradientLayer()
    thumbGradientLayer.frame = thumbView.bounds
    thumbGradientLayer.cornerRadius = thumbView.frame.height / 2
    thumbGradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    thumbGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    thumbGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    thumbGradientLayer.borderWidth = 2.0
    thumbGradientLayer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.51)
    addShadow(to: thumbGradientLayer)

    thumbView.layer.addSublayer(thumbGradientLayer)
  }

  private func setup(emptySliderView: UIView) {

    emptySliderView.backgroundColor = UIColor.white
    emptySliderView.layer.opacity = 0.68
    addShadow(to: emptySliderView.layer)
  }

  private func addShadow(to layer: CALayer) {

    layer.shadowOffset = CGSize(width: 2, height: 2)
    layer.shadowRadius = 10.0
    layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    layer.shadowOpacity = 0.11
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    guard let touch = touches.first else { return }
    let touchPoint = touch.location(in: self)

    if thumbView.frame.contains(touchPoint) {
      isHoldingThumb = true
      updateValue(for: touchPoint)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)

    if isHoldingThumb, let touch = touches.first {
      let touchPoint = touch.location(in: self)
      updateValue(for: touchPoint)
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    isHoldingThumb = false
    onValueSubmitted?(value)
  }

  private func updateValue(for point: CGPoint) {

    value = GradientSlider.maxValue * Double(point.x/bounds.width)
    onValueChanged?(value)
  }
}
