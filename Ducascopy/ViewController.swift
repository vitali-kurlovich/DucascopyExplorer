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

        let image = UIImage(named: "monkey")
        let images = image?.images

        print("\(images?.count ?? 0)")

        imageView?.image = image
        imageView?.startAnimating()
    }

    @IBOutlet
    var imageView: UIImageView?

    @IBAction
    func onStart() {
        // fetch()

        let picker = AssetPickerViewController()

        present(picker, animated: true)
    }

    func fetch() {
        Task {
            do {
                let instruments = try await Providers.instrumentsCollectionProvider.fetch()
                print(instruments)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
