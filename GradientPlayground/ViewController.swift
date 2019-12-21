//
//  ViewController.swift
//  GradientPlayground
//
//  Created by Roland Tolnay on 04/06/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var classicSwitch: UISwitch!
  @IBOutlet weak var `switch`: GradientSwitch!
  @IBOutlet weak var slider: GradientBarControl!
  @IBOutlet weak var gradientSlider: GradientSlider!

  override func viewDidLoad() {
    super.viewDidLoad()

    slider.onValueChanged = { level in

      print("Updated level: \(level)")
    }

    `switch`.attemptedToSwitch = { isOn in

      print("Attempted to switch \(isOn)")
    }

    gradientSlider.onValueChanged = { value in

      print("Slider value changes \(value)")
    }

    gradientSlider.onValueSubmitted = { value in

      print("Slider value submitted \(value)")
    }
  }
	@IBAction func onSetOn(_ sender: Any) {
		
		`switch`.setOn(true)
    classicSwitch.setOn(true, animated: true)
    gradientSlider.value = 100
	}
	@IBAction func onSetOff(_ sender: Any) {
		
		`switch`.setOn(false)
    classicSwitch.setOn(false, animated: true)
    gradientSlider.value = 0
	}

  @IBAction func onToggleEnabledTap(_ sender: Any) {

    `switch`.isEnabled.toggle()
    classicSwitch.isEnabled.toggle()
  }
}

