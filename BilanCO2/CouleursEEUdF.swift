//
//  CouleursEEUdF.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 24/09/2022.
//

import Foundation
import UIKit

//extension UIColor {
//}

func couleur(rouge: Double, vert: Double, bleu: Double) -> UIColor {
    /// renvoie la couleur RGB en 8 bits
    return UIColor(red: CGFloat(rouge / 255.0), green: CGFloat(vert / 255.0), blue: CGFloat(bleu / 255.0), alpha: 1.0)
}

let vert2 = couleur(rouge: 58, vert: 170, bleu: 53)
let vert1 = couleur(rouge: 149, vert: 193, bleu: 31)
let vert3 = couleur(rouge: 222, vert: 220, bleu: 0)
let jaune = couleur(rouge: 255, vert: 229, bleu: 0)
let orange = couleur(rouge: 243, vert: 146, bleu: 0)
let rougeVif = couleur(rouge: 228, vert: 31, bleu: 19)
let rouge = couleur(rouge: 190, vert: 22, bleu: 34)

let couleursEEUdF6 = [vert2, vert1, vert3, jaune, orange, rouge]
