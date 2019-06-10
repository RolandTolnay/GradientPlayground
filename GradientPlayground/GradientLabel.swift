//
//  GradientLabel.swift
//  GradientPlayground
//
//  Created by Roland Tolnay on 10/06/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class GradientLabel: UILabel {
	
	@IBInspectable
	var startColor: UIColor = #colorLiteral(red: 1, green: 0.1960784314, blue: 0.7450980392, alpha: 1) {
		didSet { setNeedsDisplay() }
	}
	
	@IBInspectable
	var endColor: UIColor = #colorLiteral(red: 1, green: 0.8235294118, blue: 0.137254902, alpha: 1) {
		didSet { setNeedsDisplay() }
	}
	
	// MARK: - Lifeycle
	override func layoutSubviews() {
		super.layoutSubviews()
		setNeedsDisplay()
	}
	
	override func drawText(in rect: CGRect) {
		
		if let gradientColor = drawGradientColor(in: rect) {
			textColor = gradientColor
		}
		super.drawText(in: rect)
	}
	
	private func drawGradientColor(in rect: CGRect) -> UIColor? {
		
		let context = UIGraphicsGetCurrentContext()
		context?.saveGState()
		defer { context?.restoreGState() }
		
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
		guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
																		colors: [startColor.cgColor, endColor.cgColor] as CFArray,
																		locations: [0.0, 1.0])
			else { return nil }
		
		let imageContext = UIGraphicsGetCurrentContext()
		imageContext?.drawLinearGradient(gradient,
																		 start: CGPoint.zero,
																		 end: CGPoint(x: rect.width, y: 0),
																		 options: [])
		let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return gradientImage.map { UIColor(patternImage: $0) }
	}
}
