//
//  ParametresCamps.swift
//  Bilan CO2 camp scout
//
//  Created by Jérôme Kasparian on 14/11/2023.
//

import Foundation

let nomFichierData = "DataInternationalCamps"


enum SorteEmission: Int {
    case duree
    case effectif
    case repasViandeRouge
    case repasViandeBlanche
    case repasVegetarien
    case repasGaz
    case distance
    case voyageTrain
    case voyageCar
    case voyageVoiture
    case voyageVoitureElectrique
    case voyageAvion
    case voyageCamion
    case voyageMaterielExpedie
    case deplacementsCar
    case deplacementsVoiture
    case deplacementsVoitureElectrique
    case achatsMateriel
    case hebergementTentes
    case hebergementMarabout
    case hebergementDur
    case optimist
    case caravelle
    case deriveur
    case canot
    case zodiac
    case essence
    case participationZoom = -1
}


// couleurs unionistes
let vert1 = couleur(rouge: 149, vert: 193, bleu: 31)
let vert3 = couleur(rouge: 222, vert: 220, bleu: 0)
let jaune = couleur(rouge: 255, vert: 229, bleu: 0)
let grisTresClair = couleur(rouge: 229, vert: 229, bleu: 234)   // équivalent du systemGray5 en mode clair. Cf https://noahgilmore.com/blog/dark-mode-uicolor-compatibility/
let bleuMarine = couleur(rouge: 0, vert: 62, bleu: 98)
//let couleursEEUdF5 = [grisTresClair, jaune, vert3, vert1, vert2, .white]
let couleurs5 = [grisTresClair, jaune, vert3, vert1, vert2, bleuMarine, .white]

let evenement = Evenement.camp

func ajusteQuantitesLiees(ligne: Int) {
    switch ligne {
    case SorteEmission.duree.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
    case SorteEmission.repasViandeRouge.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
    case SorteEmission.repasViandeBlanche.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeBlanche, priorite2: SorteEmission.repasViandeRouge, priorite3: SorteEmission.repasVegetarien)
    case SorteEmission.repasVegetarien.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasVegetarien, priorite2: SorteEmission.repasViandeRouge, priorite3: SorteEmission.repasViandeBlanche)
    case SorteEmission.effectif.rawValue:
        actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
    case SorteEmission.optimist.rawValue, SorteEmission.caravelle.rawValue, SorteEmission.deriveur.rawValue, SorteEmission.canot.rawValue, SorteEmission.zodiac.rawValue:
        actualiseValeurMaxBateaux()
    default: let dummy = 1
    }
    
}

func actualiseValeursMax() {
    actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
    ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
        actualiseValeurMaxBateaux()
}


func actualiseValeurMaxBateaux(){
    let trajetsCamionsMaxTheorique = 3 + ceil(lesEmissions[SorteEmission.optimist.rawValue].valeur / 3) + 2 * (lesEmissions[SorteEmission.caravelle.rawValue].valeur +  lesEmissions[SorteEmission.deriveur.rawValue].valeur +  lesEmissions[SorteEmission.canot.rawValue].valeur +  lesEmissions[SorteEmission.zodiac.rawValue].valeur)
    lesEmissions[SorteEmission.voyageCamion.rawValue].valeurMax = max(lesEmissions[SorteEmission.voyageCamion.rawValue].valeur, trajetsCamionsMaxTheorique)
//    lesEmissions[SorteEmission.voyageCamion.rawValue].valeur = min(lesEmissions[SorteEmission.voyageCamion.rawValue].valeur, lesEmissions[SorteEmission.voyageCamion.rawValue].valeurMax)
}

let pictoBien = "😀"
let pictoBof = "😐"
let pictoMal = "☹️"
