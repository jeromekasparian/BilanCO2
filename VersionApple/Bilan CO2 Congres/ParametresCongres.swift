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
    case repasViandeRouge
    case repasViandeBlanche
    case repasVegetarien
    case pausesCafe
    case voyageTrain
    case voyageAvionMCEco
    case voyageAvionLCEco
    case voyageAvionMCBusiness
    case voyageAvionLCBusiness
    case voyageZoom
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


let couleurs5 = [violet1, violet2, orange1, vertA, vertB, marron, .white]

let evenement = Evenement.congres

func ajusteQuantitesLiees(ligne: Int) {
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
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.hotelEco, priorite2: SorteEmission.hotelMoyen, priorite3: SorteEmission.hotelLuxe)
    case SorteEmission.hotelMoyen.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.hotelMoyen, priorite2: SorteEmission.hotelEco, priorite3: SorteEmission.hotelLuxe)
    case SorteEmission.hotelLuxe.rawValue:
        ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.hotelLuxe, priorite2: SorteEmission.hotelMoyen, priorite3: SorteEmission.hotelEco)

    case SorteEmission.voyageTrain.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageAvionLCBusiness, SorteEmission.voyageZoom])
    case SorteEmission.voyageAvionMCEco.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionMCEco, SorteEmission.voyageTrain, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageAvionLCBusiness, SorteEmission.voyageZoom])
    case SorteEmission.voyageAvionLCEco.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionLCEco, SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageAvionLCBusiness, SorteEmission.voyageZoom])
    case SorteEmission.voyageAvionMCBusiness.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionLCBusiness, SorteEmission.voyageZoom])
    case SorteEmission.voyageAvionLCBusiness.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionLCBusiness, SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageZoom])
//        ajusteMaxEtQuantiteHotelParType
    case SorteEmission.voyageZoom.rawValue:
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageZoom, SorteEmission.voyageTrain, SorteEmission.voyageAvionMCEco, SorteEmission.voyageAvionLCEco, SorteEmission.voyageAvionMCBusiness, SorteEmission.voyageAvionLCBusiness])
    default: let dummy = 1
    }
    
}


func actualiseValeursMax() {
    actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
    ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
    ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission.hotelEco, priorite2: SorteEmission.hotelMoyen, priorite3: SorteEmission.hotelLuxe)
//        actualiseValeurMaxBateaux()
}
