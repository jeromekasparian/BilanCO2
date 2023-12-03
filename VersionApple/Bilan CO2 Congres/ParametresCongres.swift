//
//  ParametresCongres.swift
//  Bilan CO2 Congres
//
//  Created by Jérôme Kasparian on 14/11/2023.
//

import Foundation

let nomFichierData = "DataInternationalCongres"


enum SorteEmission: Int {
    case duree
    case effectif
    case participationZoom
    case repasViandeRouge
    case repasViandeBlanche
    case repasVegetarien
    case pausesCafe
    case voyageTrain
    case voyageAvionMCEco
    case voyageAvionLCEco
    case voyageAvionMCBusiness
    case voyageAvionLCBusiness
    case taxiAeroport
    case taxiLocal
    case hotelEco
    case hotelMoyen
    case hotelLuxe
    case centreCongres
    case goodie
    case cleUSB
    case impression
    case distance = -1
    
//    static func > (premier: SorteEmission, deuxieme: SorteEmission) -> Bool {
//        return premier.rawValue > deuxieme.rawValue
//    }
//    static func < (premier: SorteEmission, deuxieme: SorteEmission) -> Bool {
//        return premier.rawValue < deuxieme.rawValue
//    }
//    static func >= (premier: SorteEmission, deuxieme: SorteEmission) -> Bool {
//        return premier.rawValue >= deuxieme.rawValue
//    }
//    static func <= (premier: SorteEmission, deuxieme: SorteEmission) -> Bool {
//        return premier.rawValue <= deuxieme.rawValue
//    }
}

// couleurs Unige
let violet1 = couleur(rouge: 0x9e, vert: 0x05, bleu: 0x74)
let violet2 = couleur(rouge: 0x5c, vert: 0x46, bleu: 0x9c)
let orange1 = couleur(rouge: 0xd2, vert: 0x8a, bleu: 0x8e)
let vertA = couleur(rouge: 0x17, vert: 0x6b, bleu: 0x87)
let vertB = couleur(rouge: 0x69, vert: 0xc3, bleu: 0xc6)
let marron = couleur(rouge: 0xbc, vert: 0xba, bleu: 0xa9)

//let vert1 = couleur(rouge: 149, vert: 193, bleu: 31)
//let vert3 = couleur(rouge: 222, vert: 220, bleu: 0)
//let jaune = couleur(rouge: 255, vert: 229, bleu: 0)
//let grisTresClair = couleur(rouge: 229, vert: 229, bleu: 234)   // équivalent du systemGray5 en mode clair. Cf https://noahgilmore.com/blog/dark-mode-uicolor-compatibility/
//let bleuMarine = couleur(rouge: 0, vert: 62, bleu: 98)
////let couleursEEUdF5 = [grisTresClair, jaune, vert3, vert1, vert2, .white]


let couleurs5 = [violet2, violet1, orange1, vertA, vertB, marron, .white]

let evenement = Evenement.congres

func ajusteQuantitesLiees(ligne: Int) {
    let ligneVisio = SorteEmission.participationZoom.rawValue
    let valeurVisio = ligneVisio > 0 ? lesEmissions[ligneVisio].valeur : 0
    switch ligne {
    case SorteEmission.duree.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.hotelEco, priorite2: SorteEmission.hotelMoyen, priorite3: SorteEmission.hotelLuxe)
    case SorteEmission.repasViandeRouge.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
    case SorteEmission.repasViandeBlanche.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeBlanche, priorite2: SorteEmission.repasViandeRouge, priorite3: SorteEmission.repasVegetarien)
    case SorteEmission.repasVegetarien.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasVegetarien, priorite2: SorteEmission.repasViandeRouge, priorite3: SorteEmission.repasViandeBlanche)
    case SorteEmission.effectif.rawValue:
        actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)

    case SorteEmission.hotelEco.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco, SorteEmission.hotelMoyen, SorteEmission.hotelLuxe], valeurDesAlternatives: valeurVisio)
    case SorteEmission.hotelMoyen.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelMoyen, SorteEmission.hotelEco, SorteEmission.hotelLuxe], valeurDesAlternatives: valeurVisio)
    case SorteEmission.hotelLuxe.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelLuxe, SorteEmission.hotelEco, SorteEmission.hotelMoyen], valeurDesAlternatives: valeurVisio)

    case SorteEmission.voyageTrain.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageAvionLCBusiness], valeurDesAlternatives: valeurVisio)
    case SorteEmission.voyageAvionMCEco.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionMCEco, SorteEmission.voyageTrain, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageAvionLCBusiness], valeurDesAlternatives: valeurVisio)
    case SorteEmission.voyageAvionLCEco.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionLCEco, SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageAvionLCBusiness], valeurDesAlternatives: valeurVisio)
    case SorteEmission.voyageAvionMCBusiness.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionLCBusiness], valeurDesAlternatives: valeurVisio)
    case SorteEmission.voyageAvionLCBusiness.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionLCBusiness, SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionMCBusiness], valeurDesAlternatives: valeurVisio)
//        ajusteMaxEtQuantiteHotelParType
    case SorteEmission.participationZoom.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageAvionLCBusiness], valeurDesAlternatives: valeurVisio)
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco, SorteEmission.hotelMoyen, SorteEmission.hotelLuxe], valeurDesAlternatives: valeurVisio)
    default: let dummy = 1
    }
    
}


func actualiseValeursMax() {
    actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
    ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
    ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.hotelEco, priorite2: SorteEmission.hotelMoyen, priorite3: SorteEmission.hotelLuxe)
//        actualiseValeurMaxBateaux()
}

let pictoBien = "👍"
let pictoBof = "🫳"
let pictoMal = "👎"
