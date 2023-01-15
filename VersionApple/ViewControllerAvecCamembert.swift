//
//  ViewControllerAvecCamembert.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 19/09/2022.
//

import Foundation
import UIKit

//let texteAfficherExplicationsFigures = "afficheExplicationFigures"
let facteurDonnut: CGFloat = 0.6

class ViewControllerAvecCamembert: UIViewController {
    @IBOutlet var affichageEmissions: UILabel!
    //    @IBOutlet var affichageEmissionsParPersonne: UILabel!
    //    @IBOutlet var affichageEmissionsSoutenables: UILabel!
    @IBOutlet var camembert: UIView!
//    @IBOutlet var boutonAideGraphique: UIButton!
    
    @IBOutlet var contrainteAffichageEmissionsDroitePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsDroitePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsBasPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsBasPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionHauteurPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertDroitePaysage: NSLayoutConstraint!
//    @IBOutlet var contrainteCamembertGauchePortrait: NSLayoutConstraint!
//    @IBOutlet var contrainteCamembertHautPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertCentreHPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertCentreVPaysage: NSLayoutConstraint!
    
//    var orientationResultats: Orientation = .inconnu
    let soutenabiliteDansDonnut:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
//        boutonAideGraphique.setTitle("", for: .normal)
    }
    
    // désactiver les contraintes inutiles avant d'activer les nouvelles
    func choisitContraintes(size: CGSize) -> Bool {
//        print("choisit contraintes Camembert debut")
        let nouvelleOrientation: Orientation = size.width <= size.height ? .portrait : .paysage
//        if nouvelleOrientation != orientationResultats {
//            orientationResultats = nouvelleOrientation
//            let estModePortrait = nouvelleOrientation == .portrait
            if nouvelleOrientation == .portrait && self.contrainteAffichageEmissionsDroitePaysage.isActive {
                self.contrainteAffichageEmissionsDroitePaysage.isActive = false
                self.contrainteAffichageEmissionsBasPaysage.isActive = false
//                self.contrainteCamembertHautPaysage.isActive = false
                self.contrainteCamembertDroitePaysage.isActive = false
                self.contrainteCamembertCentreVPaysage.isActive = false
                self.contrainteAffichageEmissionsDroitePortrait.isActive = true
                self.contrainteAffichageEmissionsBasPortrait.isActive = true
                self.contrainteAffichageEmissionHauteurPortrait.isActive = true
                self.contrainteCamembertCentreHPortrait.isActive = true
//                self.contrainteCamembertGauchePortrait.isActive = true
                self.affichageEmissions.textAlignment = .center
//                print("choisit contraintes fin portrait true")
                return true
            } else if nouvelleOrientation == .paysage && self.contrainteAffichageEmissionsDroitePortrait.isActive {
                self.contrainteAffichageEmissionsDroitePortrait.isActive = false
                self.contrainteAffichageEmissionsBasPortrait.isActive = false
                self.contrainteAffichageEmissionHauteurPortrait.isActive = false
                self.contrainteCamembertCentreHPortrait.isActive = false
//                self.contrainteCamembertGauchePortrait.isActive = false
                self.contrainteAffichageEmissionsDroitePaysage.isActive = true
                self.contrainteAffichageEmissionsBasPaysage.isActive = true
//                self.contrainteCamembertHautPaysage.isActive = true
                self.contrainteCamembertDroitePaysage.isActive = true
                self.contrainteCamembertCentreVPaysage.isActive = true
                self.affichageEmissions.textAlignment = .left
//                print("choisit contraintes fin paysage true")
                return true
            }
//        }
        else {
//            print("choisit contraintes fin false")
            return false
        }
    }
    
    private func getGraphStartAndEndPointsInRadians(debut: CGFloat, etendue: CGFloat) -> (graphStartingPoint: CGFloat, graphEndingPoint: CGFloat) {
        // debut et étendue en %
        return(CGFloat(2 * .pi * (debut - 0.25)), CGFloat(2 * .pi * (debut + etendue - 0.25)))
    } // func
    
    func dessineSecteur(rect: CGRect, rayon: CGFloat, debut: CGFloat, etendue: CGFloat, epaisseurTrait: CGFloat, couleurSecteur: UIColor) {
        let (angleDebutRadians, angleFinRadians) = self.getGraphStartAndEndPointsInRadians(debut: debut, etendue: etendue)
        let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        // now we can draw the progress arc
        let percentagePath = UIBezierPath(arcCenter: center, radius: rayon - (epaisseurTrait / 2), startAngle: angleDebutRadians, endAngle: angleFinRadians, clockwise: true)
        //        percentagePath.lineWidth = epaisseurTrait
        //        percentagePath.lineCapStyle = .butt
        let shape = CAShapeLayer()
        camembert.layer.addSublayer(shape)
        shape.strokeColor = couleurSecteur.cgColor
        shape.fillColor = .none
        shape.lineWidth = epaisseurTrait
        shape.lineCap = .butt
        shape.path = percentagePath.cgPath
    }
    
    
    func dessinePicto(frame: CGRect, picto: String, x: CGFloat, y: CGFloat, facteurTaille: CGFloat, alpha: CGFloat){
        if !picto.isEmpty {
            let largeurLabel = min(camembert.frame.width, camembert.frame.height) * facteurTaille / (picto.count == 1 ? 5 : 3)
            //                let largeurLabel = rayon / 1.8
            let hauteurLabel = picto.count == 1 ? largeurLabel * 0.5 : largeurLabel / 4
            let texte = UILabel(frame: CGRect(x: x - (largeurLabel / 2.0), y: y - (hauteurLabel / 2.0), width: largeurLabel, height: hauteurLabel))
            texte.numberOfLines = 1
            texte.textAlignment = .center
            texte.minimumScaleFactor = 0.2
            texte.lineBreakMode = .byTruncatingTail
            texte.font = .systemFont(ofSize: hauteurLabel)
            texte.text = picto
            texte.alpha = alpha
            camembert.addSubview(texte)
        }
    }
        
    func dessineCamembert(camembert: UIView, grandFormat: Bool, curseurActif: Bool) {
        // effacer le camembert existant
        if let sublayers = camembert.layer.sublayers {
            if !sublayers.isEmpty {
                sublayers.forEach({ $0.removeFromSuperlayer() })
            }
        } else {
            print("sublayers nil")
        }
        var debut: CGFloat = 0.0
        var referenceRayon =  max(emissionsCalculees, emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur)
        if soutenabiliteDansDonnut {
            referenceRayon =  emissionsCalculees
        }
        var camembertVide: Bool = true
        let rayon = min(camembert.frame.width, camembert.frame.height) / 2 * 0.9 * sqrt(emissionsCalculees / referenceRayon)
        let frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height) //camembert.frame //CGRect(x: 50, y: 100, width: 200, height: 200)
        let couleurSeparationNoire = UIColor.black
        let couleurSeparationClaire = UIColor.white
//        if #available(iOS 13.0, *) {
//            couleurSeparation = .label
//        }
//        print("debut donnut")
        var ligne: Int = 0
//        if !premierAffichageApresInitialisation {
            for emission in lesEmissions {
                if emission.emission > 0 {
                    //                print("emission non vide : ",emission.nom, emission.valeur, emission.emission)
                    camembertVide = false
                    let intervalle = emission.emission / emissionsCalculees
                    let numeroSection = lesSections.firstIndex(where: {$0.nom == emission.categorie}) ?? 0
                    let agrandirSecteur = ligne == ligneEnCours || (ligneEnCours == SorteEmission.distance.rawValue && emission.parKmDistance > 0.0) // || (ligneEnCours == SorteEmission.duree.rawValue && emission.parJour > 0.0) || (ligneEnCours == SorteEmission.effectif.rawValue && emission.parPersonne > 0.0)
                    let rayonPourPartDeCamembert = agrandirSecteur ? rayon * 1.1 : rayon
                    dessineSecteur(rect: frame, rayon: rayonPourPartDeCamembert, debut: debut, etendue: intervalle, epaisseurTrait: rayon * facteurDonnut, couleurSecteur: couleursEEUdF5[numeroSection])
                    debut = debut + intervalle
                    dessineSecteur(rect: frame, rayon: rayonPourPartDeCamembert, debut: debut - 0.0025, etendue: 0.005, epaisseurTrait: rayon * facteurDonnut, couleurSecteur: couleurSeparationNoire)
                } // if emission.valeur > 0
                ligne = ligne + 1
            } // for
//        }
        // la référence de soutenabilité
        if !camembertVide {
            if soutenabiliteDansDonnut {
                if lesEmissions[SorteEmission.effectif.rawValue].valeur > 0 {
                    //                let rayonCercleVert = rayon * (1 - facteurDonnut)
                    let ratioSoutenabilite = emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur / emissionsCalculees
                    let seuilHaut = 1.3
                    let seuilMilieu = 1.0
                    let seuilBas = 0.7
                    let taillePicto: CGFloat = 1.8
                    if ratioSoutenabilite > seuilHaut {
                        dessinePicto(frame: frame, picto: "😀", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
                    } else if ratioSoutenabilite < seuilBas {
                        dessinePicto(frame: frame, picto: "☹️", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
                    } else if curseurActif {
                        if ratioSoutenabilite > seuilMilieu {
                            dessinePicto(frame: frame, picto: "😐", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (seuilHaut - ratioSoutenabilite) / (seuilHaut - seuilMilieu))
                            dessinePicto(frame: frame, picto: "😀", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (ratioSoutenabilite - seuilMilieu) / (seuilHaut - seuilMilieu))
                        } else {  // entre 1 et le seuil bas
                            dessinePicto(frame: frame, picto: "☹️", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (seuilMilieu - ratioSoutenabilite) / (seuilMilieu - seuilBas))
                            dessinePicto(frame: frame, picto: "😐", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (ratioSoutenabilite - seuilBas) / (seuilMilieu - seuilBas))
                            
                        }
                    } else {
                        if ratioSoutenabilite > seuilMilieu + ((seuilHaut - seuilMilieu) / 2.0 ) {
                            dessinePicto(frame: frame, picto: "😀", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
                        } else if ratioSoutenabilite < seuilMilieu - ((seuilMilieu - seuilBas) / 2.0 ) {
                            dessinePicto(frame: frame, picto: "☹️", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
                        } else {
                            dessinePicto(frame: frame, picto: "😐", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
                        }
                    }
                }
            } else {
                let rayonCercleVert = min(frame.width, frame.height) / 2 * 0.9 * sqrt(emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur / referenceRayon)
                dessineSecteur(rect: frame, rayon: rayonCercleVert, debut: 0.0, etendue: 1.0, epaisseurTrait: min(frame.width, frame.height) / 50.0, couleurSecteur: .green.withAlphaComponent(0.8))
            }
//            print("soutenabilite ok")
            // écrire la légende des éléments principaux dans le camembert
            let emissionsClassees = lesEmissions.count <= 1 ? lesEmissions : lesEmissions.sorted(by: {$0.emission > $1.emission}).filter({$0.emission > 0})
            let nombreMaxiLabels = afficherPictos ? (grandFormat ? 12 : 8) : 5
            let limite = emissionsClassees.isEmpty ? 0.0 : emissionsClassees.count >= nombreMaxiLabels ? emissionsClassees[nombreMaxiLabels - 1].emission : emissionsClassees.last?.emission ?? 0.0 // on affiche les 4 postes d'émission les plus importants, à condition qu'ils soient non-nuls
            let pourcentageMini = grandFormat ? 0.03 : 0.05
            var positionPourAffichageEnGrand: CGFloat = -1
            var lignePourAffichageEnGrand: Int = -1
            var intervallePourAffichageEnGrand: CGFloat = -1
//            print("labels")
            if limite > 0 {
                debut = 0.0
                var ligne: Int = 0
                for emission in lesEmissions {
                    let intervalle = emission.emission / emissionsCalculees
                    if ligne == ligneEnCours && emission.facteurEmission > 0 {
                        positionPourAffichageEnGrand = debut
                        lignePourAffichageEnGrand = ligne
                        intervallePourAffichageEnGrand = intervalle
                    } else {
//                        let taillePicto = ligne == ligneEnCours ? 1.5 : 1.0
                        if (emission.emission >= limite && intervalle > pourcentageMini) || ligne == ligneEnCours { // on n'affiche le nom des émissions que si elles sont au moins 5% du total, et seulement les 5 principales
                            let positionAngulaireLabel: Double = 2.0 * .pi * Double(debut + (intervalle / 2.0) - 0.25)
                            dessinePicto(frame: frame, picto: emission.picto, x: CGFloat(camembert.frame.width + rayon * cos(positionAngulaireLabel) * 1.5) / 2.0, y: (camembert.frame.height + rayon * sin(positionAngulaireLabel) * 1.5) / 2.0, facteurTaille: 1.0, alpha: 1.0)
                            
                        }
                    }
                    debut = debut + intervalle
                    ligne = ligne + 1
                }
                if positionPourAffichageEnGrand >= 0 {
                    let positionAngulaireLabel = Double (2 * .pi * (positionPourAffichageEnGrand + (intervallePourAffichageEnGrand / 2.0) - 0.25))
                    dessineSecteur(rect: frame, rayon: rayon * 1.1, debut: positionPourAffichageEnGrand - 0.0025, etendue: 0.005, epaisseurTrait: rayon * facteurDonnut * 1.2, couleurSecteur: couleurSeparationClaire)
                    dessineSecteur(rect: frame, rayon: rayon * 1.1, debut: positionPourAffichageEnGrand + intervallePourAffichageEnGrand - 0.0025, etendue: 0.005, epaisseurTrait: rayon * facteurDonnut * 1.2, couleurSecteur: couleurSeparationClaire)
                    dessinePicto(frame: frame, picto: lesEmissions[lignePourAffichageEnGrand].picto, x: CGFloat(camembert.frame.width + rayon * cos(positionAngulaireLabel) * 1.5) / 2.0, y: (camembert.frame.height + rayon * sin(positionAngulaireLabel) * 1.5) / 2.0, facteurTaille: 1.5, alpha: 1.0)
                }
            }
        } else { // else : if camembertVide : indispensable de mettre quelque chose pour éviter les crashes lors de la mise en page de la subview
            dessinePicto(frame: frame, picto: " ", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: 2.0, alpha: 1)
        } // else : if camembertVide
//        print("fin camembert")
    }
    
//    @IBAction func afficheExplicationsFigure() {
////        ligneExplicationsSelectionnee = 1
//        performSegue(withIdentifier: "Explications", sender: nil)
//    }
    
    
    @objc func actualiseAffichageEmissions(grandFormat: Bool) {
        DispatchQueue.main.async{
            self.affichageEmissions.attributedText = self.texteEmissions(typesEmissions: lesEmissions, grandFormat: grandFormat)
        }
    }
    
    func texteEmissions(typesEmissions: [TypeEmission], grandFormat: Bool) -> NSAttributedString { //}(String, UIColor) {
        let emissionsParPersonne = emissionsCalculees / typesEmissions[SorteEmission.effectif.rawValue].valeur
        var couleur: UIColor = .black
        let texte = NSMutableAttributedString(string: "")
        let tailleTextePrincipal: CGFloat =  max(0.5, 3.0 * sqrt(affichageEmissions.frame.width * affichageEmissions.frame.height) / 200.0)  //grandFormat ? 3 : 2
        let tailleTexteSecondaire = 0.75 * tailleTextePrincipal
        let tailleTexteSoutenabilite = 0.75 * tailleTexteSecondaire
//        if typesEmissions[SorteEmission.effectif.rawValue].valeur > 0 && !emissionsCalculees.isNaN && emissionsCalculees > 0 { //} && !premierAffichageApresInitialisation {
        if emissionsCalculees > 0 {
//            if !boutonExport.isEnabled {boutonExport.isEnabled = true}
            
            let formatTexteValeurEmissionsTotales = emissionsCalculees < 1000.0 ? NSLocalizedString("%.0f kg", comment: "") : emissionsCalculees < 100000.0 ? NSLocalizedString("%.1f t", comment: "") : NSLocalizedString("%.0f t", comment: "")
            let emissionsPourAffichage = emissionsCalculees >= 1000 ? emissionsCalculees / 1000.0 : emissionsCalculees
            texte.append(NSMutableAttributedString(string: String(format: NSLocalizedString("CO₂ : ", comment: "") + formatTexteValeurEmissionsTotales, emissionsPourAffichage), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTextePrincipal, weight: .regular)]))
            if typesEmissions[SorteEmission.effectif.rawValue].valeur > 0 {
                if emissionsParPersonne >= 1000 {
                    texte.append(NSAttributedString(string: String(format: NSLocalizedString("\n%.1f t / personne\n", comment: ""), emissionsParPersonne / 1000.0), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSecondaire, weight: .regular)]))
                } else {
                    texte.append(NSAttributedString(string: String(format: NSLocalizedString("\n%.0f kg / personne\n", comment: ""), emissionsParPersonne), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSecondaire, weight: .regular)]))
                    
                }
                //
                let dureeEquivalenteSoutenableAns = emissionsParPersonne / emissionsSoutenablesAnnuelles
                let dureeEquivalenteSoutenableMois = dureeEquivalenteSoutenableAns * 12
                let dureeEquivalenteSoutenableJours = dureeEquivalenteSoutenableAns * 365
                if dureeEquivalenteSoutenableJours <= 60 {
                    texte.append(NSAttributedString(string: String(format: NSLocalizedString("En %.0f jours, ce camp produit autant que %.0f jours d'émissions acceptables pour préserver le climat", comment: ""), typesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableJours), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite, weight: .regular)]))
                } else if dureeEquivalenteSoutenableMois < 24 {
                    texte.append(NSAttributedString(string: String(format: NSLocalizedString("En %.0f jours, ce camp produit autant que %.0f mois d'émissions acceptables pour préserver le climat", comment: ""), typesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableMois), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite, weight: .regular)]))
                } else {
                    texte.append(NSAttributedString(string: String(format: NSLocalizedString("En %.0f jours, ce camp produit autant que %.0f ans d'émissions acceptables pour préserver le climat", comment: ""), typesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableAns), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite, weight: .regular)]))
                }
                let ratio = emissionsParPersonne == 0 ? 0.0 : emissionsParPersonne / emissionsSoutenables
                //            let ratio = emissionsSoutenables / emissionsParPersonne
                couleur = couleurSoutenabilite(ratioSoutenabilite: ratio)
                //            if ratio < 0.8 {couleur = vert2}
                //            else if ratio < 1.2 {couleur = orange}
                //            else {couleur = rougeVif}
            } else {
                couleur = .black
                texte.addAttributes([NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTextePrincipal, weight: .regular)], range: NSRange(location: 0, length: texte.length))
            }
            texte.addAttributes([NSAttributedString.Key.foregroundColor : couleur], range: NSRange(location: 0, length: texte.length))
            return NSAttributedString(attributedString: texte) //
        } else {
//            if boutonExport.isEnabled {boutonExport.isEnabled = false}
            return NSAttributedString(string: NSLocalizedString("Indiquez les caractéristiques de votre camp pour évaluer ses émissions de gaz à effet de serre", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: couleur, NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite)])
        }
    }
    

    
//    func remettreBoutons(){
//        boutonExport.isHidden = false
//        if emissionsCalculees > 0 {
//            boutonExport.isEnabled = true
//        }
////        boutonAideGraphique.isHidden = false
//    }
    
    func texteListeEmissions(lesEmissions: [TypeEmission]) -> NSAttributedString {
        let texte = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
        var categorie = ""
        for emission in lesEmissions {
            if emission.emission > 0 {
                if emission.categorie != categorie {
                    categorie = emission.categorie
                    texte.append(NSAttributedString(string: "\n" + categorie + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
                }
//                let textePicto = afficherPictos && !emission.picto.isEmpty ? emission.picto + " " : ""
                if emission.emission < 2000.0 {
                    texte.append(NSAttributedString(string: texteNomValeurUnite(emission: emission, afficherPictos: afficherPictos) + String(format: NSLocalizedString(", %.0f kg CO₂ (%.0f%%)\n", comment: ""), emission.emission, emission.emission / emissionsCalculees * 100.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.2)]))
                } else {
                    texte.append(NSAttributedString(string: texteNomValeurUnite(emission: emission, afficherPictos: afficherPictos) + String(format: NSLocalizedString(", %.2f t CO₂ (%.0f%%)\n", comment: ""), emission.emission / 1000.0, emission.emission / emissionsCalculees * 100.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.2)]))
                }
            }
        }
        if emissionsCalculees < 2000.0 {
            texte.append(NSAttributedString(string: String(format: NSLocalizedString("\nTotal : %.0f kg CO₂", comment: ""), emissionsCalculees), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
        } else {
            texte.append(NSAttributedString(string: String(format: NSLocalizedString("\nTotal : %.2f t CO₂", comment: ""), emissionsCalculees / 1000), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
        }
        texte.append(NSAttributedString(string: NSLocalizedString("\n\nAnalysez et réduisez l'impact climatique de votre camp avec l'app ", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.2)]))
        texte.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize * 1.2)], range: (texte.string as NSString).range(of: NSLocalizedString("Bilan CO2 camp scout", comment: "")))
//        texte.append(NSAttributedString(string: NSLocalizedString("Bilan CO2 camp scout", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)]))
        return texte
    }
}
