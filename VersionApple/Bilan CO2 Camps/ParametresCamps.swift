//
//  ParametresCamps.swift
//  Bilan CO2 camp scout
//
//  Created by Jérôme Kasparian on 14/11/2023.
//

import Foundation
import UIKit
// couleurs unionistes
let vert1 = couleur(rouge: 149, vert: 193, bleu: 31)
let vert3 = couleur(rouge: 222, vert: 220, bleu: 0)
let jaune = couleur(rouge: 255, vert: 229, bleu: 0)
let grisTresClair = couleur(rouge: 229, vert: 229, bleu: 234)   // équivalent du systemGray5 en mode clair. Cf https://noahgilmore.com/blog/dark-mode-uicolor-compatibility/
let bleuMarine = couleur(rouge: 0, vert: 62, bleu: 98)

let leCamp = Camp() as DescriptionEvenement
var lEvenement = leCamp

let texteMethodo = NSLocalizedString("texteMethodoCamp", comment: "")
let texteGraphique = NSLocalizedString("texteGraphiqueCamp", comment: "")
let texteEmissionsAcceptables = NSLocalizedString("texteEmissionsAcceptablesCamp", comment: "")
let texteRessourcesPedagogiques = NSLocalizedString("texteRessourcesPedagogiques", comment: "")
let texteLimites = NSLocalizedString("texteLimitesCamp", comment: "")
let texteSources = NSLocalizedString("texteSourcesCamp", comment: "")
let texteRemerciements = NSLocalizedString("texteRemerciementsCamp", comment: "")
let lesTextes = [texteMethodo, texteEmissionsAcceptables, texteRessourcesPedagogiques, texteLimites, texteSources, texteRemerciements]
let lesParagraphes = [NSLocalizedString("Méthodologie & hypothèses", comment: ""), NSLocalizedString("Émissions acceptables pour préserver le climat", comment: ""),
    NSLocalizedString("Ressources pédagogiques", comment: ""),
    NSLocalizedString("Limites", comment: ""),
    NSLocalizedString("Sources", comment: ""),
   NSLocalizedString("Remerciements", comment: "")]

class Camp: DescriptionEvenement, DescriptionEvenementDelegate {
    
    init() {
        super.init(nomFichierData: "DataInternationalCamps", pictoBien: "😀", pictoBof: "😀", pictoMal: "☹️", evenement: .camp, couleurs5:  [grisTresClair, jaune, vert3, vert1, vert2, bleuMarine, .white], texteCetEvenement: NSLocalizedString("ce camp", comment: ""), texteEmissionsDeMonEvenement: NSLocalizedString("Les émissions de CO₂ de mon camp", comment: ""), texteNomApp: NSLocalizedString("Bilan CO2 camp scout", comment: ""), texteLienAppStore: NSLocalizedString("lienAppStoreCamp", comment: ""), texteCopyright: NSLocalizedString("© 2023 Jérôme Kasparian, EEUdF", comment: ""), texteAdresseWeb: NSLocalizedString("www.eeudf.org", comment: ""), texteLienWeb: NSLocalizedString("https://www.eeudf.org", comment: ""), texteImpactClimat: NSLocalizedString("Impact climat de mon camp", comment: ""), texteAnalysezReduisez: NSLocalizedString("\n\nAnalysez et réduisez l'impact climatique de votre camp avec l'app Camp", comment: ""), texteIndiquezCaracteristiques: NSLocalizedString("Indiquez les caractéristiques de votre camp pour évaluer ses émissions de gaz à effet de serre", comment: ""), keyData: "keyValeursUtilisateurs", logo: UIImage(named: "logo eeudf coul"), numeroItemDuree: SorteEmission.duree.rawValue, numeroItemEffectif: SorteEmission.effectif.rawValue, numeroItemDistance: SorteEmission.distance.rawValue)
        self.delegate = self
    }

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
    
    
    func ajusterQuantitesLiees(ligne: Int) {
        switch ligne {
        case SorteEmission.duree.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.repasViandeRouge.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.repasViandeBlanche.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.repasVegetarien.rawValue:
            ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasVegetarien.rawValue, SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        case SorteEmission.effectif.rawValue:
            actualiseValeursMaxEffectif()
        case SorteEmission.optimist.rawValue, SorteEmission.caravelle.rawValue, SorteEmission.deriveur.rawValue, SorteEmission.canot.rawValue, SorteEmission.zodiac.rawValue:
            actualiseValeurMaxBateaux()
        default: let dummy = 1
        }
        
    }
    
    func actualiserValeursMax() {
        actualiseValeursMaxEffectif()
        ajusteMaxEtTotalNLignes(priorites: [SorteEmission.repasViandeRouge.rawValue, SorteEmission.repasViandeBlanche.rawValue, SorteEmission.repasVegetarien.rawValue], valeurDesAlternatives: 0.0, forcerDerniereValeur: true)
        actualiseValeurMaxBateaux()
    }
    
    
    func actualiseValeurMaxBateaux(){
        let trajetsCamionsMaxTheorique = 3 + ceil(lesEmissions[SorteEmission.optimist.rawValue].valeur / 3) + 2 * (lesEmissions[SorteEmission.caravelle.rawValue].valeur +  lesEmissions[SorteEmission.deriveur.rawValue].valeur +  lesEmissions[SorteEmission.canot.rawValue].valeur +  lesEmissions[SorteEmission.zodiac.rawValue].valeur)
        lesEmissions[SorteEmission.voyageCamion.rawValue].valeurMax = max(lesEmissions[SorteEmission.voyageCamion.rawValue].valeur, trajetsCamionsMaxTheorique)
        //    lesEmissions[SorteEmission.voyageCamion.rawValue].valeur = min(lesEmissions[SorteEmission.voyageCamion.rawValue].valeur, lesEmissions[SorteEmission.voyageCamion.rawValue].valeurMax)
    }

//    func calculeEmissions(typesEmissions: [TypeEmission]) -> Double {
//        return super.calculeEmissions(typesEmissions: typesEmissions, nombreJours: typesEmissions[SorteEmission.duree.rawValue].valeur, effectif: typesEmissions[SorteEmission.effectif.rawValue].valeur, distance: typesEmissions[SorteEmission.distance.rawValue].valeur)
//    }


}

func switchCollectifIndividuel(mode: Int) {
    print("inutile pour les camps")
}
