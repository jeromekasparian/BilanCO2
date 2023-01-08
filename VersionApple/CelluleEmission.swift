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
