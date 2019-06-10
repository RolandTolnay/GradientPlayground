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
	
	static let maxValue: Double = 100
	static let minValue: Double = 0
	
	var onValueChanged: ((_ value: Double) -> Void)?
	
	@IBInspectable
	var value: Double = 100 {
		didSet {
			value = value.clamped(to: GradientBarControl.minValue...GradientBarControl.maxValue)
			setNeedsDisplay()
		}
	}
	
	@IBInspectable
	var startColor: UIColor = #colorLiteral(red: 1, green: 0.1960784314, blue: 0.7450980392, alpha: 1) {
		didSet { setNeedsDisplay() }
	}
	
	@IBInspectable
	var endColor: UIColor = #colorLiteral(red: 1, green: 0.8235294118, blue: 0.137254902, alpha: 1) {
		didSet { setNeedsDisplay() }
	}
	
	var thumbDiameter: CGFloat = 28.0
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}
	
	private let sliderLayer = CAGradientLayer()
	private let thumbLayer = CAGradientLayer()
	
	private func setup() {
		
		sliderLayer.frame = CGRect(x: 0, y: frame.height / 2, width: frame.width, height: 2)
		sliderLayer.colors = [startColor.cgColor, endColor.cgColor]
		sliderLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		sliderLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		sliderLayer.shadowOffset = CGSize(width: 2, height: 2)
		sliderLayer.shadowRadius = 10.0
		sliderLayer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		sliderLayer.shadowOpacity = 0.11
		layer.addSublayer(sliderLayer)
		
		thumbLayer.frame = CGRect(x: 0,
															y: frame.height / 2 - thumbDiameter / 2 + 1,
															width: thumbDiameter,
															height: thumbDiameter)
		thumbLayer.cornerRadius = thumbLayer.frame.height / 2
		thumbLayer.colors = [startColor.cgColor, endColor.cgColor]
		thumbLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		thumbLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		thumbLayer.borderWidth = 2.0
		thumbLayer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.51)
		thumbLayer.shadowOffset = CGSize(width: 2, height: 2)
		thumbLayer.shadowRadius = 10.0
		thumbLayer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		thumbLayer.shadowOpacity = 0.11
		layer.insertSublayer(thumbLayer, above: sliderLayer)
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
}
