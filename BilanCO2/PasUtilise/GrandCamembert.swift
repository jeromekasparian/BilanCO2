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
        redessineResultats(size: self.view.frame.size)
        boutonFermer.setTitle("", for: .normal)
    }
    
    @IBAction func fermerGrandCamembert() {
        self.dismiss(animated: true)
    }
    
    func redessineResultats(size: CGSize) {
        DispatchQueue.main.async {
            let delai = self.choisitContraintes(size: size) ? 0.05 : 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delai) {
                self.dessineCamembert(camembert: self.camembert, grandFormat: false)
                self.actualiseAffichageEmissions(grandFormat: true)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        redessineResultats(size: size)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = self.view.frame.size
        redessineResultats(size: size)
    }



}

