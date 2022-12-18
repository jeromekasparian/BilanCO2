//
//  Data.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 04/09/2022.
//

// infos for the data
// facteur d'émission pour la durée : 2 repas végétariens par jour (0,51 kg CO2 par repas, soit 1,02 par jour); les repas avec viande (rouge 6.29 kg CO2, blanche 1.35 kg CO2) sont le supplément par rapport à ça

import Foundation
import UIKit

let separateur = ";" // le séparateur dans les fichiers de données

//class CaracteristiquesCamp {
//    var effectif: Int = 25
//    var distance: Double = 150 // distance entre le lieu de camp et le local
//    var duree: Int = 15 // en jours
//    
//    init() {}
//    
//    init(effectif: Int, distance: Double, duree: Int) {
//        self.effectif = effectif
//        self.distance = distance
//        self.duree = duree
//    }
//}

enum SorteEmission: Int {
    case duree = 0
    case effectif = 1
    case repasViandeRouge = 2
    case repasViandeBlanche = 3
    case repasVegetarien = 4
    case repasGaz = 5
    case distance = 6
    case voyageTrain = 7
    case voyageCar = 8
    case voyageVoiture = 9
    case voyageVoitureElectrique = 10
    case voyageBateau = 11
    case voyageAvion = 12
    case voyageCamion = 13
    case voyageMaterielExpedie = 14
    case deplacementsCar = 15
    case deplacementsVoiture = 16
    case deplacementsVoitureElectrique = 17
    case hebergementTentes = 18
    case hebergementMarabout = 19
    case hebergementDur = 20
    case achatsMateriel = 21
//    case nomCourt = 21
//    case picto = 22
}

class TypeEmission {
    var categorie: String
    var nom: String
    var unite: String
    var valeurMax: Double
    var valeur: Double
    var facteurEmission: Double
    var parPersonne: Double
    var parKmDistance: Double
    var parJour: Double
    var echelleLog: Bool
    var valeurEntiere: Bool
    var valeurMaxSelonEffectif: Double
    var valeurMaxNbRepas: Double
    var emission: Double
    var conseil: String
    var nomCourt: String
    var picto: String
    var nomsRessources: [String]
    var liensRessources: [String]
    
    init(categorie: String, nom: String, unite: String, valeurMax: Double, valeur: Double, facteurEmission: Double, parPersonne: Double, parKmDistance: Double, parJour: Double, echelleLog: Bool, valeurEntiere: Bool, valeurMaxSelonEffectif: Double, valeurMaxNbRepas: Double, emission: Double, conseil: String, nomCourt: String, picto: String, nomsRessources: [String], liensRessources: [String]) {
        self.categorie = categorie
        self.nom = nom
        self.unite = unite
        self.valeurMax = valeurMax
        self.valeur = valeur
        self.facteurEmission = facteurEmission
        self.parPersonne = parPersonne
        self.parKmDistance = parKmDistance
        self.parJour = parJour
        self.echelleLog = echelleLog
        self.valeurEntiere = valeurEntiere
        self.valeurMaxSelonEffectif = valeurMaxSelonEffectif
        self.valeurMaxNbRepas = valeurMaxNbRepas
        self.emission = emission
        self.conseil = conseil
        self.nomCourt = nomCourt.isEmpty ? nom : nomCourt
        self.picto = picto
        self.nomsRessources = nomsRessources
        self.liensRessources = liensRessources
    }
}

func calculeEmissions(typesEmissions: [TypeEmission]) -> Double {
    emissionsSoutenables = emissionsSoutenablesAnnuelles / 365 * typesEmissions[SorteEmission.duree.rawValue].valeur // kg eq CO₂ par personne
    var total: Double = 0.0    
    for typeEmission in typesEmissions {
        if typeEmission.facteurEmission > 0 {
            var multiplicateur: Double = 1
            multiplicateur = typeEmission.parPersonne == 0 ? multiplicateur : multiplicateur * typeEmission.parPersonne * typesEmissions[SorteEmission.effectif.rawValue].valeur
            multiplicateur = typeEmission.parKmDistance == 0 ? multiplicateur : multiplicateur * typeEmission.parKmDistance * typesEmissions[SorteEmission.distance.rawValue].valeur
            multiplicateur = typeEmission.parJour == 0 ? multiplicateur : multiplicateur * typeEmission.parJour * typesEmissions[SorteEmission.duree.rawValue].valeur
            typeEmission.emission = typeEmission.valeur * typeEmission.facteurEmission * multiplicateur
            total = total + typeEmission.emission
        }
    }
    return total
}


func decodeCSV(data: String) -> ([TypeEmission], [String]) {
    var lesEmetteursLus: [TypeEmission] = []
    var lesSections: [String] = []
    let lignes = data.components(separatedBy: .newlines).dropFirst()
    for ligne in lignes {
        let elements = ligne.components(separatedBy: separateur)
        if elements.count >= 17 {  // on teste une ligne vide en début ou fin de tableau
            let valeurMax = Double(elements[3]) ?? 0
            let facteurEmission = Double(elements[4]) ?? 0
            let parPersonne = Double(elements[5]) ?? 0
            let parKmParcouru = Double(elements[6]) ?? 0
            let parJour = Double(elements[7]) ?? 0
            let echelleLog = (Int(elements[8]) ?? 0) == 1
            let valeurEntiere = (Int(elements[9]) ?? 0) == 1
            let valeurMaxSelonEffectif = Double(elements[10]) ?? 0
            let valeurMaxNbRepas = Double(elements[11]) ?? 0
            let valeur = 0.0 //facteurEmission > 0 ? 0.0 : 1.0  // pour la durée et l'effectif, on met 1 par défaut, pas zéro
            let nomsRessources = elements[15].components(separatedBy: ",").filter({!$0.isEmpty})
            let liensRessources = elements[16].components(separatedBy: ",").filter({!$0.isEmpty})
            lesEmetteursLus.append(TypeEmission(categorie: elements[0], nom: elements[1], unite: elements[2], valeurMax: valeurMax, valeur: valeur, facteurEmission: facteurEmission, parPersonne: parPersonne, parKmDistance: parKmParcouru, parJour: parJour, echelleLog: echelleLog, valeurEntiere: valeurEntiere, valeurMaxSelonEffectif: valeurMaxSelonEffectif, valeurMaxNbRepas: valeurMaxNbRepas, emission: 0.0, conseil: elements[12], nomCourt: elements[13], picto: elements[14], nomsRessources: nomsRessources, liensRessources: liensRessources))
            if lesSections.isEmpty || lesSections.last != elements[0] {
                lesSections.append(elements[0])
            }
        } // si ligne correcte
    } // for
    return (lesEmetteursLus, lesSections)
}

func lireFichier(nom: String) -> ([TypeEmission], [String]) {
    // dans le DocumentDirectory si on est en train de charger un géonames monde entier et qu'on dédoublonne
    if let url = Bundle.main.url(forResource: nom, withExtension: "csv") {
        do {
            let dataString = try String(contentsOf: url, encoding: .utf8)
            return decodeCSV(data: dataString)
        }
        catch (let erreur) {
            print ("csv data conversion error")
            print(erreur)
            return ([], [])
        }
    } else {
        print("erreur à l'ouverture du fichier", nom.appending(".csv"))
        return ([], [])
    }
}
        

func arrondi(_ nombre: Double) -> Double { // arrondi à deux chiffres significatifs
    if nombre < 100 {
        return round(nombre)
    } else {
        let nombreChiffres = Int(ceil(log(nombre) / log(10.0) + 0.01))
        let facteur = pow(10, Double(nombreChiffres - 2))
        return facteur * round(nombre / facteur)
    }
}

