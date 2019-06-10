//
//  GradientSwitch.swift
//  GradientPlayground
//
//  Created by Roland Tolnay on 06/06/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit

protocol Animatable {

  var isAnimating: Bool { get }
  func startAnimating()
  func stopAnimating()
}

typealias ActivityIndicator = (Animatable & UIView)

@IBDesignable
class GradientSwitch: UIControl {

  private static let animationDuration: CFTimeInterval = 0.25
  private static let disabledOpacity: Float = 0.65

  // MARK: - IBInspectables
  @IBInspectable
  var thumbInset: CGFloat = 4.0 {
    didSet { setup() }
  }

  @IBInspectable
  var thumbDelta: CGFloat = 8.0 {
    didSet { setup() }
  }

  @IBInspectable
  var startColor: UIColor = #colorLiteral(red: 1, green: 0.1960784314, blue: 0.7450980392, alpha: 1) {
    didSet { setup() }
  }

  @IBInspectable
  var endColor: UIColor = #colorLiteral(red: 1, green: 0.8235294118, blue: 0.137254902, alpha: 1) {
    didSet { setup() }
  }

  override var isEnabled: Bool {
    didSet {
      if isEnabled != oldValue {
        animateOpacity(toIsEnabled: isEnabled)
      }
    }
  }

  @IBInspectable
  private(set) var isOn: Bool = false

  private(set) var isLoading: Bool = false

  var activityIndicator: ActivityIndicator = UIActivityIndicatorView(style: .gray)

  var attemptedToSwitch: ((Bool) -> Void)?

  func setOn(_ isOn: Bool) {

    let wasOn = self.isOn
    let settingToOn = isOn

    guard wasOn != settingToOn || isLoading else { return }

    if isLoading {
      if wasOn {
        if settingToOn {
          animateThumbPosition(toIsOn: settingToOn)
          animateBackground(toIsOn: settingToOn)
        }
      } else {
        // was off
        if settingToOn  {
          animateBackground(toIsOn: settingToOn)
        } else {
          animateThumbPosition(toIsOn: settingToOn)
        }
      }
      toggle(isLoading: false)
    } else {
      // wasn't loading
      animateBackground(toIsOn: settingToOn)
      animateThumbPosition(toIsOn: settingToOn)
    }

    self.isOn = settingToOn
    gradientLayer.shadowOpacity = settingToOn ? 0.11 : 0
  }

  // MARK: - Lifeycle
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

  // MARK: - Properties
  private let gradientLayer = CAGradientLayer()
  private let thumbLayer = CALayer()

  private func gradientBorderColor(isOn: Bool) -> CGColor {
    return isOn ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5123608733) : #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
  }

  private func gradientBorderWidth(isOn: Bool) -> CGFloat {
    return isOn ? thumbInset / 2 : frame.height / 2
  }

  private func thumbCenter(isOn: Bool) -> CGPoint {
    return isOn
      ? CGPoint(x: bounds.width - thumbLayer.frame.width / 2 - thumbInset,
                y: bounds.height - thumbLayer.frame.height / 2 - thumbInset)
      : CGPoint(x: thumbInset + thumbLayer.frame.width / 2,
                y: thumbInset + thumbLayer.frame.height / 2)
  }

  private var thumbPushedSize: CGSize {
    return CGSize(width: thumbLayer.bounds.width + thumbDelta,
                  height: thumbLayer.bounds.height)
  }

  private var thumbPushedCenter: CGPoint {
    return isOn
      ? CGPoint(x: thumbCenter(isOn: isOn).x - thumbDelta + thumbInset,
                y: thumbCenter(isOn: isOn).y)
      : CGPoint(x: thumbCenter(isOn: isOn).x + thumbDelta - thumbInset,
                y: thumbCenter(isOn: isOn).y)
  }

  // MARK: - Setup
  private func setup() {

    layer.cornerRadius = frame.height / 2

    setup(gradient: gradientLayer)
    layer.addSublayer(gradientLayer)

    setup(thumbLayer: thumbLayer)
    layer.addSublayer(thumbLayer)

    activityIndicator.frame = thumbLayer.frame
    addSubview(activityIndicator)
  }

  private func setup(thumbLayer: CALayer) {

    let thumbOrigin = isOn
      ? CGPoint(x: frame.width - frame.height + thumbInset, y: thumbInset)
      : CGPoint(x: thumbInset, y: thumbInset)

    let thumbDiameter = frame.height - thumbInset * 2
    let thumbSize = CGSize(width: thumbDiameter, height: thumbDiameter)

    thumbLayer.frame = CGRect(origin: thumbOrigin, size: thumbSize)
    thumbLayer.cornerRadius = frame.height / 2 - thumbInset
    thumbLayer.backgroundColor = UIColor.white.cgColor
    thumbLayer.shadowColor = UIColor.black.cgColor
    thumbLayer.shadowOpacity = 0.15
    thumbLayer.shadowRadius = 8.0
    thumbLayer.shadowOffset = CGSize(width: 0, height: 3)
  }

  private func setup(gradient: CAGradientLayer) {

    gradient.cornerRadius = layer.cornerRadius
    gradient.frame = bounds
    gradient.colors = [startColor.cgColor, endColor.cgColor]
    gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1.0, y: 0.5)

    gradient.shadowColor = UIColor.black.cgColor
    gradient.shadowOpacity = isOn ? 0.11 : 0
    gradient.shadowRadius = 10.0
    gradient.shadowOffset = CGSize(width: 2, height: 2)

    gradient.borderColor = gradientBorderColor(isOn: isOn)
    gradient.borderWidth = gradientBorderWidth(isOn: isOn)
  }

  // MARK: - Touch handling
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)

    let thumbBounds = CGRect(origin: CGPoint.zero, size: thumbLayer.bounds.size)
    let thumbPushedBounds = CGRect(origin: CGPoint.zero, size: thumbPushedSize)

    let thumbBoundsAnimation = baseAnimation(for: "bounds",
                                             fromValue: thumbBounds,
                                             toValue: thumbPushedBounds)
    thumbBoundsAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

    let thumbPosAnimation = baseAnimation(for: "position",
                                          fromValue: thumbCenter(isOn: isOn),
                                          toValue: thumbPushedCenter)
    thumbPosAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

    let thumbGroup = baseAnimationGroup(from: [thumbBoundsAnimation, thumbPosAnimation])

    thumbLayer.removeAllAnimations()
    thumbLayer.add(thumbGroup, forKey: "onPressAnimation")

    activityIndicator.layer.removeAnimation(forKey: "positionAnimation")
    activityIndicator.layer.add(thumbPosAnimation, forKey: "positionAnimation")
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)

    thumbLayer.removeAnimation(forKey: "onPressAnimation")
    animateThumbPosition(toIsOn: !isOn)

    if isOn {
      animateBackground(toIsOn: false)
    }

    attemptedToSwitch?(!isOn)
    toggle(isLoading: true)
  }

  private func toggle(isLoading: Bool) {

    self.isLoading = isLoading
    isUserInteractionEnabled = !isLoading
    isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
  }

  private func animateThumbPosition(toIsOn isOn: Bool) {

    let thumbPosAnimation = baseAnimation(for: "position",
                                          fromValue: thumbCenter(isOn: !isOn),
                                          toValue: thumbCenter(isOn: isOn))
    thumbPosAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)

    thumbLayer.removeAnimation(forKey: "positionAnimation")
    thumbLayer.add(thumbPosAnimation, forKey: "positionAnimation")

    activityIndicator.layer.removeAnimation(forKey: "positionAnimation")
    activityIndicator.layer.add(thumbPosAnimation, forKey: "positionAnimation")
  }

  private func animateBackground(toIsOn isOn: Bool) {

    let gradientBorderWidthAnim = baseAnimation(for: "borderWidth",
                                                fromValue: gradientBorderWidth(isOn: !isOn),
                                                toValue: gradientBorderWidth(isOn: isOn),
                                                duration: GradientSwitch.animationDuration * 1.2)
    gradientBorderWidthAnim.timingFunction = CAMediaTimingFunction(name: isOn ? .easeOut : .easeIn)

    let gradientBorderColorAnim = baseAnimation(for: "borderColor",
                                                fromValue: gradientBorderColor(isOn: !isOn),
                                                toValue: gradientBorderColor(isOn: isOn),
                                                duration: GradientSwitch.animationDuration * 1.2)
    gradientBorderColorAnim.timingFunction = CAMediaTimingFunction(name: isOn ? .easeOut : .easeIn)

    let gradientGroup = baseAnimationGroup(from: [gradientBorderWidthAnim, gradientBorderColorAnim],
                                           duration: GradientSwitch.animationDuration * 1.2)

    gradientLayer.removeAnimation(forKey: "borderAnimations")
    gradientLayer.add(gradientGroup, forKey: "borderAnimations")
  }

  private func animateOpacity(toIsEnabled isEnabled: Bool) {

    let opacityAnimation = baseAnimation(for: "opacity",
                                         fromValue: isEnabled ? GradientSwitch.disabledOpacity : 1.0,
                                         toValue: isEnabled ? 1.0 : GradientSwitch.disabledOpacity)

    thumbLayer.removeAnimation(forKey: "opacityAnimation")
    thumbLayer.add(opacityAnimation, forKey: "opacityAnimation")
    gradientLayer.removeAnimation(forKey: "opacityAnimation")
    gradientLayer.add(opacityAnimation, forKey: "opacityAnimation")
    activityIndicator.layer.add(opacityAnimation, forKey: "opacityAnimation")
    activityIndicator.layer.add(opacityAnimation, forKey: "opacityAnimation")
  }

  private func baseAnimation(for keyPath: String,
                             fromValue: Any,
                             toValue: Any,
                             duration: CFTimeInterval = GradientSwitch.animationDuration) -> CAAnimation {

    let animation = CABasicAnimation(keyPath: keyPath)
    animation.fromValue = fromValue
    animation.toValue = toValue
    animation.duration = duration
    animation.fillMode = .forwards
    animation.isRemovedOnCompletion = false

    return animation
  }

  private func baseAnimationGroup(from animations: [CAAnimation],
                                  duration: CFTimeInterval = GradientSwitch.animationDuration) -> CAAnimationGroup {

    let animationGroup = CAAnimationGroup()
    animationGroup.animations = animations
    animationGroup.duration = duration
    animationGroup.fillMode = .forwards
    animationGroup.isRemovedOnCompletion = false

    return animationGroup
  }
}

extension UIActivityIndicatorView: Animatable { }
