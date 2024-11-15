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
    }

    @IBAction
    func onStart() {
        fetch()
    }

    func fetch() {
        Task {
            do {
                let instruments = try await  Providers.instrumentsCollectionProvider.fetch()
                print(instruments)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}

