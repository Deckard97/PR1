//
//  DBSCANViewController.swift
//  PR1
//
//  Created by Maximilian Stumpf on 06.12.17.
//  Copyright © 2017 Maximilian Stumpf. All rights reserved.
//

import UIKit

class DBSCANViewController : UIViewController, UITextFieldDelegate {
    var image : UIImage!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var eTextField: UITextField!
    @IBOutlet weak var mpTextField: UITextField!
    @IBOutlet weak var metricSelector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eTextField.delegate = self
        mpTextField.delegate = self
        startButton.isEnabled = false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == eTextField {
            guard let e = Float(textField.text!) else {
                print("e is not of type float!")
                return false
            }
            if e>1 || e<=0 {
                print("e has to be >0 and <=1!")
                return false
            }
        } else {
            guard let mp = Int(textField.text!) else {
                print("minpts is not of Int type!")
                return false
            }
            if mp<1 {
                print("minpts has to be at least 1!")
                return false
            }
        }
        if eTextField.text! != "" && mpTextField.text! != "" {
            startButton.isEnabled = true
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textFieldShouldEndEditing(textField) {
            self.view.endEditing(true)
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let e = Float(eTextField.text!)!
        let minpts = Int(mpTextField.text!)!
        var euclidMetric = true
        switch metricSelector.selectedSegmentIndex {
        case 0:
            euclidMetric = true
        case 1:
            euclidMetric = false
        default:
            break
        }
        
        let dbscan = Clustering.init(image: image, e: e, minpts: minpts, metric: euclidMetric)
        if let vc = segue.destination as? ResultViewController {
            vc.image = dbscan.returnClusteredImage()
        }
        
    }

}
