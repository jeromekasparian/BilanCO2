//
//  ViewControllerCredits.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 09/10/2022.
//

import Foundation
import UIKit

class ViewControllerCredits: UIViewController {
    @IBOutlet var boutonFermer: UIButton!
    @IBOutlet var boutonOK: UIButton!

    override func viewDidLoad(){
        super.viewDidLoad()
//        if #available(iOS 13, *){
//            boutonOK.isHidden = true
//        }
    }
    @IBAction func fermerCredits() {
        self.dismiss(animated: true)
    }

}
