//
//  CelluleEmission.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 04/09/2022.
//

import Foundation
import UIKit

protocol CelluleEmissionDelegate: AnyObject {
    func glissiereBougee(cell: CelluleEmission)
    func finMouvementGlissiere(cell: CelluleEmission)
    func afficheConseil(cell: CelluleEmission)
}

class CelluleEmission: UITableViewCell {
        
    @IBOutlet var labelNom: UILabel!
    @IBOutlet var labelValeur: UILabel!
    @IBOutlet var glissiere: UISlider!
    @IBOutlet var boutonInfo: UIButton!
    @IBOutlet var labelEmissionIndividuelle: UILabel!
//    @IBOutlet var labelConseil: UILabel!

    @IBOutlet var contrainteGlissiereGaucheEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteGlissiereGaucheLarge: NSLayoutConstraint!
    @IBOutlet var contrainteGlissiereHautLarge: NSLayoutConstraint!
    @IBOutlet var contrainteNomEmissionVerticaleEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteNomEmissionVerticaleLarge: NSLayoutConstraint!
    @IBOutlet var contrainteNomEmissionDroiteEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteNomEmissionHautEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteBoutonInfoVerticaleLarge: NSLayoutConstraint!
    @IBOutlet var contrainteBoutonInfoVerticaleEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageValeurDroiteLarge: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageValeurDroiteEtroit: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    weak var delegate: CelluleEmissionDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    @IBAction func sliderBouge() {
        self.delegate?.glissiereBougee(cell: self)
    }
    
    @IBAction func lacheSlider() {
        self.delegate?.finMouvementGlissiere(cell: self)
    }

    @IBAction func clicBoutonInfo() {
        self.delegate?.afficheConseil(cell: self)
    }

    func choisitContraintes() {
        let estLarge = self.frame.width >= largeurMiniTableViewEcranLarge
//        DispatchQueue.main.async {
            self.contrainteGlissiereGaucheEtroit.isActive = !estLarge
            self.contrainteGlissiereGaucheLarge.isActive = estLarge
            self.contrainteGlissiereHautLarge.isActive = estLarge
            self.contrainteNomEmissionVerticaleEtroit.isActive = !estLarge
            self.contrainteNomEmissionVerticaleLarge.isActive = estLarge
            self.contrainteNomEmissionDroiteEtroit.isActive = !estLarge
            self.contrainteNomEmissionHautEtroit.isActive = !estLarge
        self.contrainteBoutonInfoVerticaleLarge.isActive = estLarge
        self.contrainteBoutonInfoVerticaleEtroit.isActive = !estLarge
        self.contrainteAffichageValeurDroiteLarge.isActive = estLarge
        self.contrainteAffichageValeurDroiteEtroit.isActive = !estLarge
            self.labelNom.numberOfLines = estLarge ? 2 : 1
//        }
//print("largeur", self.frame.width, "Cellule large", estLarge)
    }
}
