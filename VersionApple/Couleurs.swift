//
//  CouleursEEUdF.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 24/09/2022.
//

import Foundation
import UIKit


func couleur(rouge: Double, vert: Double, bleu: Double) -> UIColor {
    /// renvoie la couleur RGB en 8 bits
    return UIColor(red: CGFloat(rouge / 255.0), green: CGFloat(vert / 255.0), blue: CGFloat(bleu / 255.0), alpha: 1.0)
}


// couleurs génériques
let vert2 = couleur(rouge: 58, vert: 170, bleu: 53) // la couleur "bien" // aussi utilisée dans les couleurs unionistes
let orange = couleur(rouge: 243, vert: 146, bleu: 0)  // la couleur "moyen"
let rougeVif = couleur(rouge: 228, vert: 31, bleu: 19)
let rouge = couleur(rouge: 190, vert: 22, bleu: 34) // la couleur "mal"
//let bleuCiel = couleur(rouge: 159, vert: 197, bleu: 232)

func couleurIntermediaire(couleur1: UIColor, couleur2: UIColor, ratio: Double) -> UIColor {
    if ratio < 0 {
        return couleur1
    } else if ratio > 1 {
        return couleur2
    } else {
        let (r1,g1,b1,_) = couleur1.composantes() ?? (0, 0, 0, 0)
        let (r2,g2,b2,_) = couleur2.composantes() ?? (0, 0, 0, 0)
        return couleur(rouge: r1 * (1-ratio) + r2 * ratio, vert: g1 * (1-ratio) + g2 * ratio, bleu: b1 * (1-ratio) + b2 * ratio)
    }
}

func couleurSoutenabilite(ratioSoutenabilite: Double) -> UIColor {
    let ratioLimite = 0.7
    let couleurMauvais = rouge
    let couleurMoyen = orange
    let couleurBien = vert2
    if ratioSoutenabilite < 1 {
        return couleurIntermediaire(couleur1: couleurBien, couleur2: couleurMoyen, ratio: (ratioSoutenabilite - ratioLimite) / (1 - ratioLimite))
    } else {
            return couleurIntermediaire(couleur1: couleurMauvais, couleur2: couleurMoyen, ratio: ((2 - ratioLimite) - ratioSoutenabilite) / (1 - ratioLimite))
    }
}

extension UIColor {

    func composantes() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = fRed * 255.0
            let iGreen = fGreen * 255.0
            let iBlue = fBlue * 255.0
            let iAlpha = fAlpha * 255.0

            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
//    func niveauDeGris() -> CGFloat {
//        let (r, g, b, alpha) = self.composantes() ?? (0, 0, 0, 0)
//        return (0.299 * r + 0.587 * g + 0.114 * b) * alpha
//    }
}
