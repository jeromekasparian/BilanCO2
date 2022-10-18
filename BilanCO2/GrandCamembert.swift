//
//  Camembert.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 19/09/2022.
//

import Foundation
import UIKit

class GrandCamembert: ViewControllerAvecCamembert {

    @IBOutlet var boutonFermer: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choisitContraintes(size: self.view.frame.size)
        actualiseAffichageEmissions(grandFormat: true)
        dessineCamembert(camembert: camembert, grandFormat: true)
        boutonFermer.setTitle("", for: .normal)
    }
    
    @IBAction func fermerGrandCamembert() {
        self.dismiss(animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.choisitContraintes(size: size)
            self.dessineCamembert(camembert: self.camembert, grandFormat: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = self.view.frame.size
        DispatchQueue.main.async {
            self.choisitContraintes(size: size)
            self.dessineCamembert(camembert: self.camembert, grandFormat: true)
        }
    }



}

