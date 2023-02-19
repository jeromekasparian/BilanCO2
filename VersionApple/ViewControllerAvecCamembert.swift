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
//    let soutenabiliteDansDonnut:Bool = true
    
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
    
    func dessineSecteur(vueDeDestination: UIView, rect: CGRect, rayon: CGFloat, debut: CGFloat, etendue: CGFloat, epaisseurTrait: CGFloat, couleurSecteur: UIColor) {
        let (angleDebutRadians, angleFinRadians) = self.getGraphStartAndEndPointsInRadians(debut: debut, etendue: etendue)
        let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        // now we can draw the progress arc
        let percentagePath = UIBezierPath(arcCenter: center, radius: rayon - (epaisseurTrait / 2), startAngle: angleDebutRadians, endAngle: angleFinRadians, clockwise: true)
        //        percentagePath.lineWidth = epaisseurTrait
        //        percentagePath.lineCapStyle = .butt
        let shape = CAShapeLayer()
        vueDeDestination.layer.addSublayer(shape)
        shape.strokeColor = couleurSecteur.cgColor
        shape.fillColor = .none
        shape.lineWidth = epaisseurTrait
        shape.lineCap = .butt
        shape.path = percentagePath.cgPath
    }
    
    
    func dessinePicto(vueDeDestination: UIView, frame: CGRect, picto: String, x: CGFloat, y: CGFloat, facteurTaille: CGFloat, alpha: CGFloat){
        if !picto.isEmpty {
            let largeurLabel = min(frame.width, frame.height) * facteurTaille / (picto.count == 1 ? 5 : 3)
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
            vueDeDestination.addSubview(texte)
        }
    }
    
    func dedoublonnePictosDansEmissions(lesEmissions: [TypeEmission], ligneActive: Int) -> ([TypeEmission], Int) {
        var tableauCummule: [TypeEmission] = []
        var ligneActiveCorrigee = ligneActive
        var compteurLigne = 0
        for emission in lesEmissions {
            let emissionCopiee = emission.duplique() //TypeEmission(categorie: emission.categorie, nom: emission.nom, unite: emission.unite, valeurMax: emission.valeurMax, valeur: emission.valeur, facteurEmission: emission.facteurEmission, parPersonne: emission.parPersonne, parKmDistance: emission.parKmDistance, parJour: emission.parJour, echelleLog: emission.echelleLog, valeurEntiere: emission.valeurEntiere, valeurMaxSelonEffectif: emission.valeurMaxSelonEffectif, valeurMaxNbRepas: emission.valeurMaxNbRepas, emission: emission.emission, conseil: emission.conseil, nomCourt: emission.nomCourt, picto: emission.picto, nomsRessources: emission.nomsRessources, liensRessources: emission.liensRessources, nomPluriel: emission.nomPluriel, sectionOptionnelle: emission.sectionOptionnelle)
            if tableauCummule.isEmpty {
                tableauCummule.append(emissionCopiee)
            } else {
                if tableauCummule.last?.picto == emission.picto && !emission.picto.isEmpty && tableauCummule.last?.categorie == emission.categorie {
                    tableauCummule.last?.emission = (tableauCummule.last?.emission ?? 0) + emission.emission
                    if ligneActive >= compteurLigne {
                        ligneActiveCorrigee -= 1
                    }
                } else {
                    tableauCummule.append(emissionCopiee)
                }
            }
            compteurLigne += 1
        }
        
        return (tableauCummule, ligneActiveCorrigee)
    }
    
    func dessineCamembert(camembert: UIView, curseurActif: Bool, lesEmissions: [TypeEmission], ligneActive: Int) {
        // effacer le camembert existant
        if let sublayers = camembert.layer.sublayers {
            if !sublayers.isEmpty {
                sublayers.forEach({ $0.removeFromSuperlayer() })
            }
        } else {
            print("sublayers nil")
        }
        var debut: CGFloat = 0.0
        var camembertVide: Bool = true
        let rayon = min(camembert.frame.width, camembert.frame.height) / 2 * 0.9
        let frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height) //camembert.frame //CGRect(x: 50, y: 100, width: 200, height: 200)
        let couleurSeparationNoire = UIColor.black
        let couleurSeparationClaire = UIColor.white
        
        var ligne: Int = 0
            let (lesEmissionsCompact, ligneEnCoursCorrigee) = dedoublonnePictosDansEmissions(lesEmissions: lesEmissions, ligneActive: ligneActive)
//        print("lignes : ", ligneEnCoursCorrigee, ligneActive)
//        print(lesEmissions.map({$0.emission}))
        for emission in lesEmissionsCompact {
            if emission.emission > 0 {
                camembertVide = false
                let intervalle = emission.emission / emissionsCalculees
                let numeroSection = lesSections.firstIndex(where: {$0.nom == emission.categorie}) ?? 0
                let agrandirSecteur = ligne == ligneEnCoursCorrigee || (ligneEnCoursCorrigee == SorteEmission.distance.rawValue && emission.parKmDistance > 0.0) // || (ligneEnCoursCorrigee == SorteEmission.duree.rawValue && emission.parJour > 0.0) || (ligneEnCoursCorrigee == SorteEmission.effectif.rawValue && emission.parPersonne > 0.0)
                let rayonPourPartDeCamembert = agrandirSecteur ? rayon * 1.1 : rayon
                dessineSecteur(vueDeDestination: camembert,rect: frame, rayon: rayonPourPartDeCamembert, debut: debut, etendue: intervalle, epaisseurTrait: rayon * facteurDonnut, couleurSecteur: couleursEEUdF5[numeroSection])
                debut = debut + intervalle
                dessineSecteur(vueDeDestination: camembert,rect: frame, rayon: rayonPourPartDeCamembert, debut: debut - 0.0025, etendue: 0.005, epaisseurTrait: rayon * facteurDonnut, couleurSecteur: couleurSeparationNoire)
            } // if emission.valeur > 0
            ligne = ligne + 1
        } // for
        
        if !camembertVide {
                if lesEmissions[SorteEmission.effectif.rawValue].valeur > 0 {
                    afficheSmileyDuCentre(vueDeDestination: camembert, curseurActif: curseurActif)
                }
            let emissionsClassees = lesEmissionsCompact.count <= 1 ? lesEmissionsCompact : lesEmissionsCompact.sorted(by: {$0.emission > $1.emission}).filter({$0.emission > 0})
            let nombreMaxiLabels = 8 //grandFormat ? 12 : 8
            let limite = emissionsClassees.isEmpty ? 0.0 : emissionsClassees.count >= nombreMaxiLabels ? emissionsClassees[nombreMaxiLabels - 1].emission : emissionsClassees.last?.emission ?? 0.0 // on affiche les 4 postes d'émission les plus importants, à condition qu'ils soient non-nuls
            let pourcentageMini = 0.05 //grandFormat ? 0.03 : 0.05
            var positionPourAffichageEnGrand: CGFloat = -1
            var lignePourAffichageEnGrand: Int = -1
            var intervallePourAffichageEnGrand: CGFloat = -1
            if limite > 0 {
                debut = 0.0
                var ligne: Int = 0
                for emission in lesEmissionsCompact {
                    let intervalle = emission.emission / emissionsCalculees
                    if ligne == ligneEnCoursCorrigee && emission.facteurEmission > 0 {
                        positionPourAffichageEnGrand = debut
                        lignePourAffichageEnGrand = ligne
                        intervallePourAffichageEnGrand = intervalle
                    } else if (emission.emission >= limite && intervalle > pourcentageMini) || ligne == ligneEnCoursCorrigee { // on n'affiche le nom des émissions que si elles sont au moins 5% du total, et seulement les 5 principales
                            let positionAngulaireLabel: Double = 2.0 * .pi * Double(debut + (intervalle / 2.0) - 0.25)
                            dessinePicto(vueDeDestination: camembert,frame: frame, picto: emission.picto, x: CGFloat(camembert.frame.width + rayon * cos(positionAngulaireLabel) * 1.5) / 2.0, y: (camembert.frame.height + rayon * sin(positionAngulaireLabel) * 1.5) / 2.0, facteurTaille: 1.0, alpha: 1.0)
                            
                        }
                    debut = debut + intervalle
                    ligne = ligne + 1
                } // for
                if positionPourAffichageEnGrand >= 0 {
                    let positionAngulaireLabel = Double (2 * .pi * (positionPourAffichageEnGrand + (intervallePourAffichageEnGrand / 2.0) - 0.25))
                    dessineSecteur(vueDeDestination: camembert,rect: frame, rayon: rayon * 1.1, debut: positionPourAffichageEnGrand - 0.0025, etendue: 0.005, epaisseurTrait: rayon * facteurDonnut * 1.2, couleurSecteur: couleurSeparationClaire)
                    dessineSecteur(vueDeDestination: camembert,rect: frame, rayon: rayon * 1.1, debut: positionPourAffichageEnGrand + intervallePourAffichageEnGrand - 0.0025, etendue: 0.005, epaisseurTrait: rayon * facteurDonnut * 1.2, couleurSecteur: couleurSeparationClaire)
                    dessinePicto(vueDeDestination: camembert,frame: frame, picto: lesEmissionsCompact[lignePourAffichageEnGrand].picto, x: CGFloat(camembert.frame.width + rayon * cos(positionAngulaireLabel) * 1.5) / 2.0, y: (camembert.frame.height + rayon * sin(positionAngulaireLabel) * 1.5) / 2.0, facteurTaille: 1.5, alpha: 1.0)
                }
            }
        } else { // else : if camembertVide : indispensable de mettre quelque chose pour éviter les crashes lors de la mise en page de la subview
            dessinePicto(vueDeDestination: camembert,frame: frame, picto: " ", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: 2.0, alpha: 1)
        } // else : if camembertVide
    }
    
    func afficheSmileyDuCentre(vueDeDestination: UIView, curseurActif: Bool) {
        let ratioSoutenabilite = emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur / emissionsCalculees
        let seuilHaut = 1.3
        let seuilMilieu = 1.0
        let seuilBas = 0.7
        let taillePicto: CGFloat = 1.8
        let frame = vueDeDestination.frame
        if ratioSoutenabilite > seuilHaut {
            dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "😀", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
        } else if ratioSoutenabilite < seuilBas {
            dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "☹️", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
        } else if curseurActif {
            if ratioSoutenabilite > seuilMilieu {
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "😐", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (seuilHaut - ratioSoutenabilite) / (seuilHaut - seuilMilieu))
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "😀", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (ratioSoutenabilite - seuilMilieu) / (seuilHaut - seuilMilieu))
            } else {  // entre 1 et le seuil bas
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "☹️", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (seuilMilieu - ratioSoutenabilite) / (seuilMilieu - seuilBas))
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "😐", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (ratioSoutenabilite - seuilBas) / (seuilMilieu - seuilBas))
            }
        } else {
            if ratioSoutenabilite > seuilMilieu + ((seuilHaut - seuilMilieu) / 2.0 ) {
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "😀", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
            } else if ratioSoutenabilite < seuilMilieu - ((seuilMilieu - seuilBas) / 2.0 ) {
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "☹️", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
            } else {
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: "😐", x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
            }
        }
    }
    
    @objc func actualiseAffichageEmissions() {
        DispatchQueue.main.async{
            self.affichageEmissions.attributedText = self.texteEmissions(typesEmissions: lesEmissions)
        }
    }
    
    func texteEmissions(typesEmissions: [TypeEmission]) -> NSAttributedString { //}(String, UIColor) {
        let emissionsParPersonne = emissionsCalculees / typesEmissions[SorteEmission.effectif.rawValue].valeur
        var couleur: UIColor = .black
        let texte = NSMutableAttributedString(string: "")
        let tailleTextePrincipal: CGFloat =  max(0.5, 3.0 * sqrt(affichageEmissions.frame.width * affichageEmissions.frame.height) / 200.0)  //grandFormat ? 3 : 2
        let tailleTexteSecondaire = 0.75 * tailleTextePrincipal
        let tailleTexteSoutenabilite = 0.75 * tailleTexteSecondaire
        if emissionsCalculees > 0 {
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
                couleur = couleurSoutenabilite(ratioSoutenabilite: ratio)
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
    
    
    func texteListeEmissions(lesEmissions: [TypeEmission], pourTexteBrut: Bool) -> NSAttributedString {
        let facteurPoliceTitre = 1.5
        let facteurPoliceSousTitre = 1.0
        let facteurPoliceTexte = 0.8
        let paragraphStyleCentre: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyleCentre.alignment = NSTextAlignment.center
        paragraphStyleCentre.lineBreakMode = NSLineBreakMode.byWordWrapping
        let contenu = pourTexteBrut ? "" : NSLocalizedString("Les émissions de CO₂ de mon camp", comment: "") + "\n"
        let texte = NSMutableAttributedString(string: contenu, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTitre), NSAttributedString.Key.paragraphStyle: paragraphStyleCentre]) //NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
//        texte.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))

        var categorie = ""
        for emission in lesEmissions {
            if emission.emission > 0 {
                if emission.categorie != categorie {
                    categorie = emission.categorie
                    texte.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))
                    texte.append(NSAttributedString(string: categorie + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre)]))
                }
                //                let textePicto = afficherPictos && !emission.picto.isEmpty ? emission.picto + " " : ""
                let texteLigneEmission = emission.emission < 2000.0 ? NSLocalizedString(", %.0f kg CO₂ (%.0f%%)\n", comment: "") : NSLocalizedString(", %.2f t CO₂ (%.0f%%)\n", comment: "")
                let facteurValeurEmission = emission.emission < 2000.0 ? 1.0 : 1000.0
                texte.append(NSAttributedString(string: texteNomValeurUnite(emission: emission) + String(format: texteLigneEmission, emission.emission / facteurValeurEmission, emission.emission / emissionsCalculees * 100.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))
            }
        }
        let texteTotalEmissions = emissionsCalculees < 2000.0 ? NSLocalizedString("\nTotal : %.0f kg CO₂", comment: "") : NSLocalizedString("\nTotal : %.2f t CO₂", comment: "")
        let facteurTotalEmissions = emissionsCalculees < 2000.0 ? 1.0 : 1000.0
            texte.append(NSAttributedString(string: String(format: texteTotalEmissions, emissionsCalculees / facteurTotalEmissions), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre)]))
        let emissionsParPersonne = emissionsCalculees / lesEmissions[SorteEmission.effectif.rawValue].valeur
        if lesEmissions[SorteEmission.effectif.rawValue].valeur > 0 {
            let texteEmissionsParPersonne = emissionsParPersonne < 2000 ? NSLocalizedString(" (%.1f kg / personne)\n", comment: "") : NSLocalizedString(" (%.1f t / personne)\n", comment: "")
            let facteurEmissionsParPersonne = emissionsParPersonne < 2000.0 ? 1.0 : 1000.0
            texte.append(NSAttributedString(string: String(format: texteEmissionsParPersonne, emissionsParPersonne / facteurEmissionsParPersonne), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre, weight: .regular)]))
            let dureeEquivalenteSoutenableAns = emissionsParPersonne / emissionsSoutenablesAnnuelles
            let dureeEquivalenteSoutenableMois = dureeEquivalenteSoutenableAns * 12
            let dureeEquivalenteSoutenableJours = dureeEquivalenteSoutenableAns * 365
            let ratio = emissionsParPersonne == 0 ? 0.0 : emissionsParPersonne / emissionsSoutenables
            let couleur = couleurSoutenabilite(ratioSoutenabilite: ratio)
            
            if dureeEquivalenteSoutenableJours <= 60 {
                texte.append(NSAttributedString(string: String(format: NSLocalizedString("En %.0f jours, ce camp produit autant de gaz à effet de serre que %.0f jours d'émissions acceptables pour préserver le climat", comment: ""), lesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableJours), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre, weight: .regular), NSAttributedString.Key.foregroundColor : couleur]))
            } else if dureeEquivalenteSoutenableMois < 24 {
                texte.append(NSAttributedString(string: String(format: NSLocalizedString("En %.0f jours, ce camp produit autant de gaz à effet de serre que %.0f mois d'émissions acceptables pour préserver le climat", comment: ""), lesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableMois), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre, weight: .regular), NSAttributedString.Key.foregroundColor : couleur]))
            } else {
                texte.append(NSAttributedString(string: String(format: NSLocalizedString("En %.0f jours, ce camp produit autant de gaz à effet de serre que %.0f ans d'émissions acceptables pour préserver le climat", comment: ""), lesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableAns), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre, weight: .regular), NSAttributedString.Key.foregroundColor : couleur]))
            }
        }
        texte.append(NSAttributedString(string: NSLocalizedString("\n\nAnalysez et réduisez l'impact climatique de votre camp avec l'app ", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))
//        texte.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)], range: (texte.string as NSString).range(of: NSLocalizedString("Bilan CO2 camp scout", comment: "")))
        texte.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: (texte.string as NSString).range(of: NSLocalizedString("Bilan CO2 camp scout", comment: "")))
//        texte.addAttribute(.underlineStyle, value: NSUnderlineStyle.single, range: (texte.string as NSString).range(of: NSLocalizedString("Bilan CO2 camp scout", comment: "")))
        texte.addAttribute(.link, value: NSLocalizedString("lienAppStore", comment: ""), range: (texte.string as NSString).range(of: NSLocalizedString("Bilan CO2 camp scout", comment: "")))
        if pourTexteBrut {
            texte.append(NSAttributedString(string: NSLocalizedString(" : ", comment: "") + NSLocalizedString("lienAppStore", comment: "")))
        }
        return texte
    }
}
