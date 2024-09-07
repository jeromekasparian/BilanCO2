//
//  ParametresCongres.swift
//  Bilan CO2 Congres
//
//  Created by Jérôme Kasparian on 14/11/2023.
//

import Foundation
import UIKit

// couleurs Unige
let violet1 = couleur(rouge: 0x9e, vert: 0x05, bleu: 0x74)
let violet2 = couleur(rouge: 0x5c, vert: 0x46, bleu: 0x9c)
let orange1 = couleur(rouge: 0xd2, vert: 0x8a, bleu: 0x8e)
let vertA = couleur(rouge: 0x17, vert: 0x6b, bleu: 0x87)
let vertB = couleur(rouge: 0x69, vert: 0xc3, bleu: 0xc6)
let marron = couleur(rouge: 0xbc, vert: 0xba, bleu: 0xa9)

let leCongres = Congres() as DescriptionEvenement
let leCongresIndividuel = CongresIndividuel() as DescriptionEvenement

var lEvenement = leCongres

let texteMethodo = NSLocalizedString("texteMethodoCongres", comment: "")
let texteGraphique = NSLocalizedString("texteGraphiqueCongres", comment: "")
let texteEmissionsAcceptables = NSLocalizedString("texteEmissionsAcceptablesCongres", comment: "")
let texteRessourcesPedagogiques = NSLocalizedString("texteRessourcesPedagogiques", comment: "")
let texteLimites = NSLocalizedString("texteLimitesCongres", comment: "")
let texteSources = NSLocalizedString("texteSourcesCongres", comment: "")
let texteRemerciements = NSLocalizedString("texteRemerciementsCongres", comment: "")
let lesTextes = [texteMethodo, texteEmissionsAcceptables, texteLimites, texteSources, texteRemerciements]
let lesParagraphes =  [NSLocalizedString("Méthodologie & hypothèses", comment: ""),
                       NSLocalizedString("Émissions acceptables pour préserver le climat", comment: ""),
                       NSLocalizedString("Limites", comment: ""),
                       NSLocalizedString("Sources", comment: ""),
                       NSLocalizedString("Remerciements", comment: "")]

class Congres: DescriptionEvenement, DescriptionEvenementDelegate {
    init() {
        super.init(nomFichierData: "DataInternationalCongres", pictoBien: "👍", pictoBof: "🫳", pictoMal: "👎", evenement: .congresCollectif, couleurs5: [violet2, violet1, orange1, vertA, vertB, marron, .white], texteCetEvenement: NSLocalizedString("ce congrès", comment: ""), texteEmissionsDeMonEvenement: NSLocalizedString("Les émissions de CO₂ de mon congrès", comment: ""), texteNomApp: NSLocalizedString("Bilan CO2 congrès", comment: ""), texteLienAppStore: NSLocalizedString("lienAppStoreCongres", comment: ""), texteCopyright: NSLocalizedString("© 2023 Jérôme Kasparian, Université de Genève", comment: ""), texteAdresseWeb: NSLocalizedString("www.unige.ch", comment: ""), texteLienWeb: NSLocalizedString("https://www.unige.ch", comment: ""), texteImpactClimat: NSLocalizedString("Impact climat de mon congrès", comment: ""), texteAnalysezReduisez: NSLocalizedString("\n\nAnalysez et réduisez l'impact climatique de votre congrès avec l'app Congres", comment: ""), texteIndiquezCaracteristiques: NSLocalizedString("Indiquez les caractéristiques de votre congrès pour évaluer ses émissions de gaz à effet de serre", comment: ""), keyData: "keyDataCongres", logo: UIImage(named: "Unige"), numeroItemDuree: SorteEmission.duree.rawValue, numeroItemEffectif: SorteEmission.effectif.rawValue, numeroItemDistance: SorteEmission.distance.rawValue)
        self.delegate = self
    }
    
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
        case TPAeroport
        case taxiAeroport
        case TPLocal
        case taxiLocal
        case hotelEco
        case hotelMoyen
        case hotelLuxe
        case centreCongres
        case goodie
        case cleUSB
        case impression
        case distance = -1
    }
        
    func ajusterQuantitesLiees(ligne: Int) {
        
        let ligneVisio = SorteEmission.participationZoom.rawValue
        let valeurVisio = ligneVisio > 0 ? lesEmissions[ligneVisio].valeur : 0
        switch ligne {
        case SorteEmission.duree.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
        case SorteEmission.repasViandeRouge.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.repasViandeBlanche.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.repasVegetarien.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasVegetarien.rawValue, SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.effectif.rawValue:
            actualiseValeursMaxEffectif()
            
        case SorteEmission.hotelEco.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
        case SorteEmission.hotelMoyen.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelEco.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
        case SorteEmission.hotelLuxe.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelLuxe.rawValue, SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)

        case SorteEmission.voyageTrain.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageTrain.rawValue, SorteEmission.voyageAvionMCEco.rawValue, SorteEmission.voyageAvionLCEco.rawValue, SorteEmission.voyageAvionMCBusiness.rawValue, SorteEmission.voyageAvionLCBusiness.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
        case SorteEmission.voyageAvionMCEco.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionMCEco.rawValue, SorteEmission.voyageTrain.rawValue, SorteEmission.voyageAvionLCEco.rawValue, SorteEmission.voyageAvionMCBusiness.rawValue, SorteEmission.voyageAvionLCBusiness.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
        case SorteEmission.voyageAvionLCEco.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionLCEco.rawValue, SorteEmission.voyageTrain.rawValue, SorteEmission.voyageAvionMCEco.rawValue, SorteEmission.voyageAvionMCBusiness.rawValue, SorteEmission.voyageAvionLCBusiness.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
        case SorteEmission.voyageAvionMCBusiness.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionMCBusiness.rawValue, SorteEmission.voyageTrain.rawValue, SorteEmission.voyageAvionMCEco.rawValue, SorteEmission.voyageAvionLCEco.rawValue, SorteEmission.voyageAvionLCBusiness.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
        case SorteEmission.voyageAvionLCBusiness.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionLCBusiness.rawValue, SorteEmission.voyageTrain.rawValue, SorteEmission.voyageAvionMCEco.rawValue, SorteEmission.voyageAvionLCEco.rawValue, SorteEmission.voyageAvionMCBusiness.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
            //        ajusteMaxEtQuantiteHotelParType
        case SorteEmission.participationZoom.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageTrain.rawValue, SorteEmission.voyageAvionMCEco.rawValue, SorteEmission.voyageAvionLCEco.rawValue, SorteEmission.voyageAvionMCBusiness.rawValue, SorteEmission.voyageAvionLCBusiness.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.TPAeroport.rawValue, SorteEmission.taxiAeroport.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)

        case SorteEmission.TPAeroport.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.TPAeroport.rawValue, SorteEmission.taxiAeroport.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)
        case SorteEmission.taxiAeroport.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.taxiAeroport.rawValue, SorteEmission.TPAeroport.rawValue], valeurDesAlternatives: valeurVisio, forcerDerniereValeur: false)

        case SorteEmission.TPLocal.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.TPLocal.rawValue, SorteEmission.taxiLocal.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
        case SorteEmission.taxiLocal.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.taxiLocal.rawValue, SorteEmission.TPLocal.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)

        default: let dummy = 1
        }
    }
    
    
    func actualiserValeursMax() {
        actualiseValeursMaxEffectif()
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
    }

}

class CongresIndividuel: DescriptionEvenement, DescriptionEvenementDelegate {
    init() {
        super.init(nomFichierData: "DataInternationalCongresIndividuel", pictoBien: "👍", pictoBof: "🫳", pictoMal: "👎", evenement: .congresCollectif, couleurs5: [violet2, violet1, orange1, vertA, vertB, marron, .white], texteCetEvenement: NSLocalizedString("ma participation à ce congrès", comment: ""), texteEmissionsDeMonEvenement: NSLocalizedString("Les émissions de CO₂ de ma participation au congrès", comment: ""), texteNomApp: NSLocalizedString("Bilan CO2 congrès", comment: ""), texteLienAppStore: NSLocalizedString("lienAppStoreCongres", comment: ""), texteCopyright: NSLocalizedString("© 2023 Jérôme Kasparian, Université de Genève", comment: ""), texteAdresseWeb: NSLocalizedString("www.unige.ch", comment: ""), texteLienWeb: NSLocalizedString("https://www.unige.ch", comment: ""), texteImpactClimat: NSLocalizedString("Impact climat de ma participation au congrès", comment: ""), texteAnalysezReduisez: NSLocalizedString("\n\nAnalysez et réduisez l'impact climatique de votre congrès avec l'app Congres", comment: ""), texteIndiquezCaracteristiques: NSLocalizedString("Indiquez les caractéristiques de votre voyage pour évaluer ses émissions de gaz à effet de serre", comment: ""), keyData: "keyDataCongresIndividuel", logo: UIImage(named: "Unige"), numeroItemDuree: SorteEmission.duree.rawValue, numeroItemEffectif: SorteEmission.effectif.rawValue, numeroItemDistance: SorteEmission.distance.rawValue)
        self.delegate = self
    }
    
    enum SorteEmission: Int {
        case duree
        case distance
        case participationZoom
        case repasViandeRouge
        case repasViandeBlanche
        case repasVegetarien
        case pausesCafe
        case voyageTrain
        case voyageAvionEco
        case voyageAvionBusiness
        case TPAeroport
        case taxiAeroport
        case TPLocal
        case taxiLocal
        case hotelEco
        case hotelMoyen
        case hotelLuxe
        case goodie
        case cleUSB
        case impression
        case effectif = -1
    }

    func ajusterQuantitesLiees(ligne: Int) {
        switch ligne {
        case SorteEmission.duree.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
        case SorteEmission.repasViandeRouge.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.repasViandeBlanche.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.repasVegetarien.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasVegetarien.rawValue, SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
            
        case SorteEmission.hotelEco.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
        case SorteEmission.hotelMoyen.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelEco.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
        case SorteEmission.hotelLuxe.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelLuxe.rawValue, SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
            
        case SorteEmission.voyageTrain.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageTrain.rawValue, SorteEmission.voyageAvionEco.rawValue, SorteEmission.voyageAvionBusiness.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
        case SorteEmission.voyageAvionEco.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionEco.rawValue, SorteEmission.voyageTrain.rawValue,  SorteEmission.voyageAvionBusiness.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
        case SorteEmission.voyageAvionBusiness.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.voyageAvionBusiness.rawValue, SorteEmission.voyageTrain.rawValue, SorteEmission.voyageAvionEco.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
        default: let dummy = 1
        }
    }
    
    func actualiserValeursMax() {
        actualiseValeursMaxEffectif()
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.hotelEco.rawValue, SorteEmission.hotelMoyen.rawValue, SorteEmission.hotelLuxe.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: false)
    }

    
}


func switchCollectifIndividuel(mode: Int) {
    lEvenement = mode == 0 ? leCongres : leCongresIndividuel
}
