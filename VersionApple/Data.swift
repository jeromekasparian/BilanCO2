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

enum Evenement: Int {
    case camp
    case congresCollectif
    case congresIndividuel
}

protocol DescriptionEvenementDelegate: AnyObject {
    func actualiserValeursMax()
    func ajusterQuantitesLiees(ligne: Int)
}

class DescriptionEvenement {
    var lesEmissions: [TypeEmission] = []
    var sections: [Section] = []
    var nomFichierData: String = ""
    var pictoBien: String = ""
    var pictoBof: String = ""
    var pictoMal: String = ""
    var couleurs5: [UIColor] = []
    var evenement: Evenement
    var texteCetEvenement: String = ""
    var texteEmissionsDeMonEvenement: String = ""
    var texteNomApp: String = ""
    var texteLienAppStore: String = ""
    var texteCopyright: String = ""
    var texteAdresseWeb: String = ""
    var texteLienWeb: String = ""
    var texteImpactClimat: String = ""
    var texteAnalysezReduisez: String = ""
    var texteIndiquezCaracteristiques: String = ""

    var keyData: String = ""

    var logo: UIImage? = nil

    var numeroItemDuree: Int = -1
    var numeroItemEffectif: Int = -1
    var numeroItemDistance: Int = -1
    
    weak var delegate: DescriptionEvenementDelegate?
    
    init(nomFichierData: String, pictoBien: String, pictoBof: String, pictoMal: String, evenement: Evenement, couleurs5: [UIColor], texteCetEvenement: String, texteEmissionsDeMonEvenement: String, texteNomApp: String, texteLienAppStore: String, texteCopyright: String, texteAdresseWeb: String, texteLienWeb: String, texteImpactClimat: String, texteAnalysezReduisez: String, texteIndiquezCaracteristiques : String, keyData: String, logo: UIImage?, numeroItemDuree: Int, numeroItemEffectif: Int, numeroItemDistance: Int) {
        self.evenement = evenement
        self.nomFichierData = nomFichierData
        (self.lesEmissions, self.sections) = lireFichier(nom: nomFichierData)
        self.pictoBien = pictoBien
        self.pictoBof = pictoBof
        self.pictoMal = pictoMal
        self.couleurs5 = couleurs5
        
        self.texteCetEvenement = texteCetEvenement
        self.texteEmissionsDeMonEvenement = texteEmissionsDeMonEvenement
        self.texteNomApp = texteNomApp
        self.texteLienAppStore = texteLienAppStore
        self.texteCopyright = texteCopyright
        self.texteAdresseWeb = texteAdresseWeb
        self.texteLienWeb = texteLienWeb
        self.texteImpactClimat = texteImpactClimat
        self.texteAnalysezReduisez = texteAnalysezReduisez
        self.texteIndiquezCaracteristiques = texteIndiquezCaracteristiques
        self.keyData = keyData
        
        self.logo = logo

        self.numeroItemDuree = numeroItemDuree
        self.numeroItemDistance = numeroItemDistance
        self.numeroItemEffectif = numeroItemEffectif
        
        let lesValeurs = userDefaults.value(forKey: keyData) as? [Double] ?? []
        if !lesValeurs.isEmpty && lesValeurs.count == self.lesEmissions.count {
            for i in 0...lesValeurs.count - 1 {
                self.lesEmissions[i].valeur = lesValeurs[i]
            }
        }

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
    
    
    func actualiseValeursMaxEffectif() {
        if self.numeroItemEffectif >= 0 {
            let effectif = lesEmissions[numeroItemEffectif].valeur
            for i in 0...lesEmissions.count-1 {
                if lesEmissions[i].valeurMaxSelonEffectif > 0 {
                    let collerAuMax = lesEmissions[i].valeur == lesEmissions[i].valeurMax && lesEmissions[i].valeurMax > 0.0
                    lesEmissions[i].valeurMax = effectif * lesEmissions[i].valeurMaxSelonEffectif
                    if collerAuMax {
                        lesEmissions[i].valeur = lesEmissions[i].valeurMax
                    } else {
                        lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
                    }
                }
            }
        }
    }
    
    func actualiseValeursMaxSelonJours() {
        if self.numeroItemDuree >= 0 {
            let nombreJours = lesEmissions[numeroItemDuree].valeur
            for i in 0...lesEmissions.count-1 {
                if lesEmissions[i].valeurMaxParJour > 0 {
                    let collerAuMax = lesEmissions[i].valeur == lesEmissions[i].valeurMax && lesEmissions[i].valeurMax > 0.0
                    lesEmissions[i].valeurMax = nombreJours * lesEmissions[i].valeurMaxParJour
                    if collerAuMax {
                        lesEmissions[i].valeur = lesEmissions[i].valeurMax
                    } else {
                        lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
                    }
                }
            }
        }
    }
    
    func actualiseValeursMax() {
        self.delegate?.actualiserValeursMax()
    }
    
    func ajusteQuantitesLiees(ligne: Int) {
        self.delegate?.ajusterQuantitesLiees(ligne: ligne)
    }
    
    func ajusteMaxEtTotalNLignes(priorites: [Int], valeurDesAlternatives: Double, forcerDerniereValeur: Bool) {
        guard !priorites.isEmpty else {return}
        //        let nombreJours = lesEmissions[SorteEmission.duree.rawValue].valeur
        let valeurMaxi = (lesEmissions[priorites.first!].valeurMaxParJour == 0 ? lesEmissions[priorites.first!].valeurMax : lesEmissions[numeroItemDuree].valeur * lesEmissions[priorites.first!].valeurMaxParJour) - valeurDesAlternatives
        actualiseValeursMaxSelonJours()
        lesEmissions[priorites.first!].valeur = min(lesEmissions[priorites.first!].valeur, valeurMaxi)
        guard priorites.count >= 2 else {return}
        var cumul = lesEmissions[priorites.first!].valeur
        for i in 1...(priorites.count - 1) {
            if i == priorites.count - 1 && forcerDerniereValeur {
                lesEmissions[priorites[i]].valeur = valeurMaxi - cumul
            } else {
                lesEmissions[priorites[i]].valeur = min(lesEmissions[priorites[i]].valeur, valeurMaxi - cumul)
                cumul = cumul + lesEmissions[priorites[i]].valeur
            }
        }
    }
    
    func calculeEmissions(typesEmissions: [TypeEmission]) -> Double {
        let nombreJours = lesEmissions[numeroItemDuree].valeur
        let distance = numeroItemDistance >= 0 ? lesEmissions[numeroItemDistance].valeur : -1.0
        emissionsSoutenables = emissionsSoutenablesAnnuelles / 365.25 * nombreJours // kg eq CO₂ par personne
        var total: Double = 0.0
        for typeEmission in typesEmissions {
            if typeEmission.facteurEmission != 0 {
                var multiplicateur: Double = 1.0
                if typeEmission.parPersonne != 0 && numeroItemEffectif >= 0 {
                    multiplicateur = multiplicateur * typeEmission.parPersonne * lesEmissions[numeroItemEffectif].valeur
                }
                if typeEmission.parKmDistance != 0 && distance >= 0 {
                    multiplicateur = multiplicateur * typeEmission.parKmDistance * distance
                }
                if typeEmission.parJour != 0 {
                    multiplicateur = multiplicateur * typeEmission.parJour * nombreJours
                }
                    typeEmission.emission = typeEmission.valeur * typeEmission.facteurEmission * multiplicateur
                    total = total + typeEmission.emission
            }
            for i in 0...sections.count - 1 {
                let lesEmissionsDeLaSection = lesEmissions.filter({$0.categorie == sections[i].nom}).map({$0.emission})
                sections[i].emissionsSection = lesEmissionsDeLaSection.reduce(0.0, +)
                if sections[i].emissionsSection > 0 {
                    sections[i].afficherLaSection = true
                }
            }
        }
        return total
    }
    
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
    var texteNomValeur = ""
    if emission.unite.isEmpty {
        texteNomValeur = String(format: "%.0f " + nom, emission.valeur)
    } else {
        let unite = emission.valeur > 1 && !emission.nomPluriel.isEmpty ? emission.nomPluriel : emission.unite
        texteNomValeur = emission.nom + String(format: NSLocalizedString(" : %.0f ", comment: "") + unite, emission.valeur)
    }
    if emission.picto.isEmpty {
        return texteNomValeur
    } else {
        return emission.picto + " " + texteNomValeur
    }
}

