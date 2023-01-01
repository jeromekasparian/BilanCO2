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
        redessineResultats(size: self.view.frame.size, curseurActif: false)
        boutonFermer.setTitle("", for: .normal)
    }
    
    @IBAction func fermerGrandCamembert() {
        self.dismiss(animated: true)
    }
    
    func redessineResultats(size: CGSize, curseurActif: Bool) {
        DispatchQueue.main.async {
            let delai = self.choisitContraintes(size: size) ? 0.05 : 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delai) {
                self.dessineCamembert(camembert: self.camembert, grandFormat: false, curseurActif: curseurActif)
                self.actualiseAffichageEmissions(grandFormat: true)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        redessineResultats(size: size, curseurActif: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = self.view.frame.size
        redessineResultats(size: size, curseurActif: false)
    }



}

