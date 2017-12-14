//
//  ResultViewController.swift
//  PR1
//
//  Created by Maximilian Stumpf on 06.12.17.
//  Copyright © 2017 Maximilian Stumpf. All rights reserved.
//

import UIKit

class ResultViewController : UIViewController {
    var image : UIImage!
    
    @IBOutlet weak var resultImage : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultImage.image = image
    }
    
    @IBAction func doneButtonTapped (_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
