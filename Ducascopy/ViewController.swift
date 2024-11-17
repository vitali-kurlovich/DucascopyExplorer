//
//  ViewController.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        imageView?.preferredSymbolConfiguration =
            imageView?.preferredSymbolConfiguration?.applying(UIImage.SymbolConfiguration.preferringMulticolor())

        imageView?.addSymbolEffect(.variableColor.iterative.dimInactiveLayers)
    }

    @IBOutlet
    var imageView: UIImageView?

    @IBOutlet
    var button: UIButton?

    @IBAction
    func onStart() {
        let picker = AssetPickerViewController()
        present(picker, animated: true)
    }

    @IBAction
    func buttonTouchDown() {
        imageView?.addSymbolEffect(.bounce.down)
        button?.imageView?.addSymbolEffect(.bounce)
    }
}
