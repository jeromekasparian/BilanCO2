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
    func debutMouvementGlissiere(cell: CelluleEmission)
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
//    @IBOutlet var contrainteGlissiereHautLarge: NSLayoutConstraint!
    @IBOutlet var contrainteNomEmissionVerticaleEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteNomEmissionVerticaleLarge: NSLayoutConstraint!
    @IBOutlet var contrainteNomEmissionDroiteEtroit: NSLayoutConstraint!
//    @IBOutlet var contrainteNomEmissionHautEtroit: NSLayoutConstraint!
//    @IBOutlet var contrainteBoutonInfoVerticaleLarge: NSLayoutConstraint!
//    @IBOutlet var contrainteBoutonInfoVerticaleEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageValeurDroiteLarge: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageValeurDroiteEtroit: NSLayoutConstraint!

//    var largeurCellule: LargeurCellule = .inconnu
    
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
    
    @IBAction func attrappeSlider() {
        self.delegate?.debutMouvementGlissiere(cell: self)
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

    func choisitContraintesCelluleEmission(largeurTableView: CGFloat) {
//        print("choisit contraintes cell debut")
//        let nouvelleLargeur: LargeurCellule = self.frame.width >= largeurMiniTableViewEcranLarge ? .large : .etroit
//        if nouvelleLargeur != largeurCellule {
//            largeurCellule = nouvelleLargeur
//            let estLarge = self.frame.width >= largeurMiniTableViewEcranLarge //nouvelleLargeur == .large
        let largeurCellule = largeurTableView
        let estLarge = (largeurCellule - labelNom.textWidth() - labelValeur.textWidth() - boutonInfo.frame.width - 12 - 32)  >= largeurMiniGlissiere // 12 : les intervalles ; 32 : les marges à gauche et à droite
//        print("contraintes", labelNom.text!, largeurCellule, labelNom.textWidth(), glissiere.frame.width, labelValeur.textWidth(), boutonInfo.frame.width, largeurCellule - labelNom.textWidth() - labelValeur.textWidth() - boutonInfo.frame.width - 12 - 32, estLarge, contrainteAffichageValeurDroiteLarge.isActive)
            //        DispatchQueue.main.async {
        if estLarge { // désactiver les contraintes avant d'activer les autres
//            print("Large", labelNom.text)
            self.contrainteGlissiereGaucheEtroit.isActive = false
            self.contrainteNomEmissionVerticaleEtroit.isActive = false
            self.contrainteNomEmissionDroiteEtroit.isActive = false
//            self.contrainteNomEmissionHautEtroit.isActive = false
//            self.contrainteBoutonInfoVerticaleEtroit.isActive = false
            self.contrainteAffichageValeurDroiteEtroit.isActive = false
            self.contrainteGlissiereGaucheLarge.isActive = true
//            self.contrainteGlissiereHautLarge.isActive = true
            self.contrainteNomEmissionVerticaleLarge.isActive = true
//            self.contrainteBoutonInfoVerticaleLarge.isActive = true
            self.contrainteAffichageValeurDroiteLarge.isActive = true
//            self.labelNom.numberOfLines = 2
        } else {
//            print("Etroit", labelNom.text)
            self.contrainteGlissiereGaucheLarge.isActive = false
//            self.contrainteGlissiereHautLarge.isActive = false
            self.contrainteNomEmissionVerticaleLarge.isActive = false
//            self.contrainteBoutonInfoVerticaleLarge.isActive = false
            self.contrainteAffichageValeurDroiteLarge.isActive = false
            self.contrainteNomEmissionVerticaleEtroit.isActive = true
            self.contrainteGlissiereGaucheEtroit.isActive = true
            self.contrainteNomEmissionDroiteEtroit.isActive = true
//            self.contrainteNomEmissionHautEtroit.isActive = true
//            self.contrainteBoutonInfoVerticaleEtroit.isActive = true
            self.contrainteAffichageValeurDroiteEtroit.isActive = true
//            self.labelNom.numberOfLines = 1
        }
//        print("choisit contraintes cell fin")

            //        }
//            print("largeur", self.frame.width, "Cellule large", estLarge)
//        }
    }
    
    func texteEmissionsLigne(typeEmission: TypeEmission) -> (String, UIColor) {
        if typeEmission.facteurEmission == 0 {
            return ("", .black)
        } else if typeEmission.emission == 0 || emissionsCalculees.isNaN {
            return ("", .black)
        } else {
            let pourcentage = typeEmission.emission / emissionsCalculees * 100.0
            let texte = String(format: NSLocalizedString("%.0f kg eq. CO₂ (%.0f%%)", comment: ""), typeEmission.emission, pourcentage)
            var couleur: UIColor = .gray
            if pourcentage > 10.0 {couleur = .black}
            if pourcentage > 20.0 {couleur = rougeVif}
            return (texte, couleur)
        }
    }

    func actualiseEmissionIndividuelle(typeEmission: TypeEmission) {
        let (texte, couleur) = texteEmissionsLigne(typeEmission: typeEmission)
        self.labelEmissionIndividuelle.text = texte
        self.labelEmissionIndividuelle.textColor = couleur
    }
}
