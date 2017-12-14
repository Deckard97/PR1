//
//  KmeansViewController.swift
//  PR1
//
//  Created by Maximilian Stumpf on 06.12.17.
//  Copyright © 2017 Maximilian Stumpf. All rights reserved.
//

import UIKit

class KmeansViewController : UIViewController, UITextFieldDelegate {
    var image : UIImage!
    
    @IBOutlet weak var kTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.isEnabled = false
        kTextField.delegate = self
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let k = Int(textField.text!) else {
            print("k is not of an Int value!")
            return false
        }
        if k<1 {
            print("k has to be at least 1")
            return false
        }
        startButton.isEnabled = true
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textFieldShouldEndEditing(textField) {
            self.view.endEditing(true)
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let k = Int(kTextField.text!)!
        let kmeans = Clustering.init(image: image, k: k)
        if let vc = segue.destination as? ResultViewController {
            vc.image = kmeans.returnClusteredImage()
        }
    }
}
