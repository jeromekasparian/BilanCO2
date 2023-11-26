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

enum Evenement: Int {
    case camp
    case congres
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
    var valeurMaxParJour: Double
    var emission: Double
    var conseil: String
    var nomCourt: String
    var picto: String
    var nomsRessources: [String]
    var liensRessources: [String]
    var nomPluriel: String
    var sectionOptionnelle: Bool
    
    init(categorie: String, nom: String, unite: String, valeurMax: Double, valeur: Double, facteurEmission: Double, parPersonne: Double, parKmDistance: Double, parJour: Double, echelleLog: Bool, valeurEntiere: Bool, valeurMaxSelonEffectif: Double, valeurMaxParJour: Double, emission: Double, conseil: String, nomCourt: String, picto: String, nomsRessources: [String], liensRessources: [String], nomPluriel: String, sectionOptionnelle: Bool) {
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
        self.valeurMaxParJour = valeurMaxParJour
        self.emission = emission
        self.conseil = conseil
        self.nomCourt = nomCourt.isEmpty ? nom : nomCourt
        self.picto = picto
        self.nomsRessources = nomsRessources
        self.liensRessources = liensRessources
        self.nomPluriel = nomPluriel
        self.sectionOptionnelle = sectionOptionnelle
    }
    
    func duplique() -> TypeEmission {
        return TypeEmission(categorie: self.categorie, nom: self.nom, unite: self.unite, valeurMax: self.valeurMax, valeur: self.valeur, facteurEmission: self.facteurEmission, parPersonne: self.parPersonne, parKmDistance: self.parKmDistance, parJour: self.parJour, echelleLog: self.echelleLog, valeurEntiere: self.valeurEntiere, valeurMaxSelonEffectif: self.valeurMaxSelonEffectif, valeurMaxParJour: self.valeurMaxParJour, emission: self.emission, conseil: self.conseil, nomCourt: self.nomCourt, picto: self.picto, nomsRessources: self.nomsRessources, liensRessources: self.liensRessources, nomPluriel: self.nomPluriel, sectionOptionnelle: self.sectionOptionnelle)
    }
}

class Section {
    var nom: String
    var emissionsSection: Double
    var optionnel: Bool
    var afficherLaSection: Bool
    
    init(nom: String, emissionsSection: Double, optionnel: Bool, afficherLaSection: Bool){
        self.nom = nom
        self.emissionsSection = emissionsSection
        self.optionnel = optionnel
        self.afficherLaSection = afficherLaSection
    }
    
}

func calculeEmissions(typesEmissions: [TypeEmission]) -> Double {
    emissionsSoutenables = emissionsSoutenablesAnnuelles / 365.25 * typesEmissions[SorteEmission.duree.rawValue].valeur // kg eq CO₂ par personne
    var total: Double = 0.0
    for typeEmission in typesEmissions {
        if typeEmission.facteurEmission != 0 {
            var multiplicateur: Double = 1.0
            if typeEmission.parPersonne != 0 {
                multiplicateur = multiplicateur * typeEmission.parPersonne * typesEmissions[SorteEmission.effectif.rawValue].valeur
            }
//            print("personne", multiplicateur)
            if typeEmission.parKmDistance != 0 && SorteEmission.distance.rawValue >= 0 {
                multiplicateur = multiplicateur * typeEmission.parKmDistance * typesEmissions[SorteEmission.distance.rawValue].valeur
            }
//            print("km", multiplicateur)
            if typeEmission.parJour != 0 {
                multiplicateur = multiplicateur * typeEmission.parJour * typesEmissions[SorteEmission.duree.rawValue].valeur
            }
//            print("jour", multiplicateur)
            typeEmission.emission = typeEmission.valeur * typeEmission.facteurEmission * multiplicateur
            print(typeEmission.nom, typeEmission.emission)
            total = total + typeEmission.emission
        }
    }
    for i in 0...lesSections.count - 1 {
        let lesEmissionsDeLaSection = lesEmissions.filter({$0.categorie == lesSections[i].nom}).map({$0.emission})
        lesSections[i].emissionsSection = lesEmissionsDeLaSection.reduce(0.0, +)
        if lesSections[i].emissionsSection > 0 {lesSections[i].afficherLaSection = true}
    }
    return total
}


func decodeCSV(data: String) -> ([TypeEmission], [Section]) {
    var lesEmetteursLus: [TypeEmission] = []
    var lesSections: [Section] = []
    let lignes = data.components(separatedBy: .newlines).dropFirst()
    for ligne in lignes {
        let elements = ligne.components(separatedBy: separateur)
        if elements.count >= 19 {  // on teste une ligne vide en début ou fin de tableau
            let categorie = NSLocalizedString(elements[0], comment: "")
            let valeurMax = Double(elements[3]) ?? 0
            let facteurEmission = Double(elements[4]) ?? 0
            let parPersonne = Double(elements[5]) ?? 0
            let parKmParcouru = Double(elements[6]) ?? 0
            let parJour = Double(elements[7]) ?? 0
            let echelleLog = (Int(elements[8]) ?? 0) == 1
            let valeurEntiere = (Int(elements[9]) ?? 0) == 1
            let valeurMaxSelonEffectif = Double(elements[10]) ?? 0
            let valeurMaxParJour = Double(elements[11]) ?? 0
//            print("valeurMaxParJour", valeurMaxParJour)
            let valeur = 0.0 //facteurEmission > 0 ? 0.0 : 1.0  // pour la durée et l'effectif, on met 1 par défaut, pas zéro
            let nomsRessources = NSLocalizedString(elements[15], comment: "").components(separatedBy: ",").filter({!$0.isEmpty})
            let liensRessources = NSLocalizedString(elements[16], comment: "").components(separatedBy: ",").filter({!$0.isEmpty})
            let sectionOptionnelle = (Int(elements[18]) ?? 0) == 1
            lesEmetteursLus.append(TypeEmission(categorie: categorie,
                                                nom: NSLocalizedString(elements[1], comment: ""),
                                                unite: NSLocalizedString(elements[2], comment: ""),
                                                valeurMax: valeurMax, valeur: valeur, facteurEmission: facteurEmission,
                                                parPersonne: parPersonne, parKmDistance: parKmParcouru, parJour: parJour,
                                                echelleLog: echelleLog, valeurEntiere: valeurEntiere,
                                                valeurMaxSelonEffectif: valeurMaxSelonEffectif,
                                                valeurMaxParJour: valeurMaxParJour, emission: 0.0,
                                                conseil: NSLocalizedString(elements[12], comment: "").replacingOccurrences(of: "\\n", with: "\n"),
                                                nomCourt: NSLocalizedString(elements[13], comment: ""), picto: elements[14],
                                                nomsRessources: nomsRessources, liensRessources: liensRessources,
                                                nomPluriel: NSLocalizedString(elements[17], comment: ""),
                                                sectionOptionnelle: sectionOptionnelle))
            if lesSections.isEmpty || (lesSections.last?.nom ?? "kzwx") != categorie {
                lesSections.append(Section(nom: categorie, emissionsSection: 0.0, optionnel: sectionOptionnelle, afficherLaSection: !sectionOptionnelle))
            }
            if valeur > 0 && sectionOptionnelle {
                lesSections.last?.afficherLaSection = true
            }
        } // si ligne correcte
    } // for
    return (lesEmetteursLus, lesSections)
}

func lireFichier(nom: String) -> ([TypeEmission], [Section]) {
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
        let nombreChiffres = Int(ceil(log(nombre) / log(10.0) + 0.001))
        let facteur = pow(10, Double(nombreChiffres - 2))
        return facteur * round(nombre / facteur)
    }
}

func texteNomValeurUnite(emission: TypeEmission) -> String { //, afficherPictos: Bool) -> String {
    let nom = emission.valeur <= 1 ? emission.nom : emission.nomPluriel
    let texteNomValeur = emission.unite.isEmpty ? String(format: "%.0f " + nom, emission.valeur) : emission.nom + String(format: NSLocalizedString(" : %.0f ", comment: "") + emission.unite, emission.valeur)
//    if afficherPictos && !emission.picto.isEmpty {
    if emission.picto.isEmpty {
        return texteNomValeur
    } else {
        return emission.picto + " " + texteNomValeur
    }
}

// pourrait être fusionné avec la version à n lignes
func ajusteMaxEtTotalTroisLignes(priorite1: SorteEmission, priorite2: SorteEmission, priorite3: SorteEmission) {
    let nombreJours = lesEmissions[SorteEmission.duree.rawValue].valeur
    let valeurMaxi = lesEmissions[priorite1.rawValue].valeurMaxParJour == 0 ? lesEmissions[priorite1.rawValue].valeurMax : nombreJours * lesEmissions[priorite1.rawValue].valeurMaxParJour
    actualiseValeursMaxSelonJours(valeurMax: valeurMaxi)
    lesEmissions[priorite1.rawValue].valeur = min(lesEmissions[priorite1.rawValue].valeur, valeurMaxi)
    lesEmissions[priorite2.rawValue].valeur = min(lesEmissions[priorite2.rawValue].valeur, valeurMaxi - lesEmissions[priorite1.rawValue].valeur)
    lesEmissions[priorite3.rawValue].valeur = valeurMaxi - lesEmissions[priorite1.rawValue].valeur - lesEmissions[priorite2.rawValue].valeur
}

func ajusteMaxEtTotalNLignes(priorites: [SorteEmission]) {
    guard !priorites.isEmpty  else {return}
    let nombreJours = lesEmissions[SorteEmission.duree.rawValue].valeur
    let valeurMaxi = lesEmissions[priorites.first!.rawValue].valeurMaxParJour == 0 ? lesEmissions[priorites.first!.rawValue].valeurMax : nombreJours * lesEmissions[priorites.first!.rawValue].valeurMaxParJour
    actualiseValeursMaxSelonJours(valeurMax: valeurMaxi)
    lesEmissions[priorites.first!.rawValue].valeur = min(lesEmissions[priorites.first!.rawValue].valeur, valeurMaxi)
    guard priorites.count > 2 else {return}
    var cumul = lesEmissions[priorites.first!.rawValue].valeur
    for i in 1...(priorites.count - 2) {
        lesEmissions[priorites[i].rawValue].valeur = min(lesEmissions[priorites[i].rawValue].valeur, valeurMaxi - cumul)
        cumul = cumul + lesEmissions[priorites[i].rawValue].valeur
    }
    lesEmissions[priorites.last!.rawValue].valeur = valeurMaxi - cumul
//    print("ajuste", priorites.last!,  lesEmissions[priorites.last!.rawValue].valeur)
//    lesEmissions[priorite2.rawValue].valeur = min(lesEmissions[priorite2.rawValue].valeur, valeurMaxi - lesEmissions[priorite1.rawValue].valeur)
//    lesEmissions[priorite3.rawValue].valeur = valeurMaxi - lesEmissions[priorite1.rawValue].valeur - lesEmissions[priorite2.rawValue].valeur
}

func actualiseValeursMaxEffectif(valeurMax: Double) {
    for i in 0...lesEmissions.count-1 {
        if lesEmissions[i].valeurMaxSelonEffectif > 0 {
            let collerAuMax = lesEmissions[i].valeur == lesEmissions[i].valeurMax && lesEmissions[i].valeurMax > 0.0
            lesEmissions[i].valeurMax = valeurMax * lesEmissions[i].valeurMaxSelonEffectif
            if collerAuMax {
                lesEmissions[i].valeur = lesEmissions[i].valeurMax
            } else {
                lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
            }
        }
    }
}

func actualiseValeursMaxSelonJours(valeurMax: Double) {
    for i in 0...lesEmissions.count-1 {
        if lesEmissions[i].valeurMaxParJour > 0 {
            let collerAuMax = lesEmissions[i].valeur == lesEmissions[i].valeurMax && lesEmissions[i].valeurMax > 0.0
            lesEmissions[i].valeurMax = valeurMax //* lesEmissions[i].valeurMaxParJour
            if collerAuMax {
                lesEmissions[i].valeur = lesEmissions[i].valeurMax
            } else {
                lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
            }
        }
    }
}
