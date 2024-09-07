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
    @IBOutlet var camembert: UIView!
    @IBOutlet var vueResultats: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // désactiver les contraintes inutiles avant d'activer les nouvelles
    func choisitContraintes(size: CGSize, orientationGlobale: Orientation) -> Bool {
        var nouvelleOrientation: Orientation = .paysage // size.width <= size.height * 1.1 ? .portrait : .paysage
        if orientationGlobale == .portrait {
            let tailleImageSiVertical = min(size.width, size.height / 4.0)
            let tauxOccupationSiVertical = tailleImageSiVertical * tailleImageSiVertical / (size.width * min(size.width, size.height / 4.0))
            let tailleImageSiHorizontal = min(size.width / 2.0, size.height / 2.0)
            let tauxOccupationSiHorizontal = tailleImageSiHorizontal * tailleImageSiHorizontal / (size.width / 2.0 * min(tailleImageSiHorizontal, size.height / 2.0))
            if tauxOccupationSiVertical > tauxOccupationSiHorizontal {
                nouvelleOrientation = .portrait
            }
        } else {  // orientationGlobale == .paysage
            let tailleImageSiVertical = min(size.width / 2, size.height / 2.0)
            let tauxOccupationSiVertical = tailleImageSiVertical * tailleImageSiVertical / (size.width / 2.0 * min(tailleImageSiVertical, size.height / 2.0))
            let tailleImageSiHorizontal = min(size.width / 4.0, size.height)
            let tauxOccupationSiHorizontal = tailleImageSiHorizontal * tailleImageSiHorizontal / (size.height * min(size.height, size.width / 4.0)) // (size.width / 2.0 * min(tailleImageSiHorizontal, size.height / 2.0))
            if tauxOccupationSiVertical > tauxOccupationSiHorizontal {
                nouvelleOrientation = .portrait
            }
        }
        if nouvelleOrientation == .portrait && self.vueResultats.axis != .vertical { // self.contrainteAffichageEmissionsDroitePaysage.isActive {
            self.vueResultats.axis = .vertical
            self.affichageEmissions.textAlignment = .center
            return true
        } else if nouvelleOrientation == .paysage &&  self.vueResultats.axis != .horizontal { // self.contrainteAffichageEmissionsDroitePortrait.isActive {
            self.vueResultats.axis = .horizontal
            self.affichageEmissions.textAlignment = .left
            return true
        }
        else {
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
            let emissionCopiee = emission.duplique()
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
                sublayers.forEach({$0.removeFromSuperlayer() })
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
        for emission in lesEmissionsCompact {
            if emission.emission > 0 {
                camembertVide = false
                let intervalle = emission.emission / emissionsCalculees
                let numeroSection = lEvenement.sections.firstIndex(where: {$0.nom == emission.categorie}) ?? 0
                let agrandirSecteur = ligne == ligneEnCoursCorrigee || (ligneEnCoursCorrigee == lEvenement.numeroItemDistance && emission.parKmDistance > 0.0) 
                let rayonPourPartDeCamembert = agrandirSecteur ? rayon * 1.1 : rayon
                dessineSecteur(vueDeDestination: camembert,rect: frame, rayon: rayonPourPartDeCamembert, debut: debut, etendue: intervalle, epaisseurTrait: rayon * facteurDonnut, couleurSecteur: lEvenement.couleurs5[numeroSection])
                debut = debut + intervalle
                dessineSecteur(vueDeDestination: camembert,rect: frame, rayon: rayonPourPartDeCamembert, debut: debut - 0.0025, etendue: 0.005, epaisseurTrait: rayon * facteurDonnut, couleurSecteur: couleurSeparationNoire)
            } // if emission.valeur > 0
            ligne = ligne + 1
        } // for
        
        if !camembertVide {
            afficheSmileyDuCentre(vueDeDestination: camembert, curseurActif: curseurActif)
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
        let effectif = lEvenement.numeroItemEffectif >= 0 ? lEvenement.lesEmissions[lEvenement.numeroItemEffectif].valeur : 1
        let ratioSoutenabilite = emissionsSoutenables * effectif / emissionsCalculees
        let seuilHaut = 1.3
        let seuilMilieu = 1.0
        let seuilBas = 0.7
        let taillePicto: CGFloat = 1.8
        let frame = vueDeDestination.frame
        if ratioSoutenabilite > seuilHaut {
            dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoBien, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
        } else if ratioSoutenabilite < seuilBas {
            dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoMal, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
        } else if curseurActif {
            if ratioSoutenabilite > seuilMilieu {
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoBof, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (seuilHaut - ratioSoutenabilite) / (seuilHaut - seuilMilieu))
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoBien, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (ratioSoutenabilite - seuilMilieu) / (seuilHaut - seuilMilieu))
            } else {  // entre 1 et le seuil bas
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoMal, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (seuilMilieu - ratioSoutenabilite) / (seuilMilieu - seuilBas))
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoBof, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: (ratioSoutenabilite - seuilBas) / (seuilMilieu - seuilBas))
            }
        } else {
            if ratioSoutenabilite > seuilMilieu + ((seuilHaut - seuilMilieu) / 2.0 ) {
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoBien, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
            } else if ratioSoutenabilite < seuilMilieu - ((seuilMilieu - seuilBas) / 2.0 ) {
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoMal, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
            } else {
                dessinePicto(vueDeDestination: vueDeDestination, frame: frame, picto: lEvenement.pictoBof, x: camembert.frame.width / 2.0, y: camembert.frame.height / 2.0, facteurTaille: taillePicto, alpha: 1)
            }
        }
    }
    
    @objc func actualiseAffichageEmissions() {
        DispatchQueue.main.async{
            self.affichageEmissions.attributedText = self.texteEmissions(typesEmissions: lEvenement.lesEmissions)
        }
    }
    
    func texteEmissions(typesEmissions: [TypeEmission]) -> NSAttributedString { //}(String, UIColor) {
        let effectif = lEvenement.numeroItemEffectif >= 0 ? typesEmissions[lEvenement.numeroItemEffectif].valeur : 1.0
        let emissionsParPersonne = emissionsCalculees / effectif
        var couleur: UIColor = .black
        let texte = NSMutableAttributedString(string: "")
        let tailleTextePrincipal: CGFloat =  max(0.5, 3.0 * sqrt(affichageEmissions.frame.width * affichageEmissions.frame.height) / 200.0)  //grandFormat ? 3 : 2
        let tailleTexteSecondaire = 0.75 * tailleTextePrincipal
        let tailleTexteSoutenabilite = 0.75 * tailleTexteSecondaire
        if emissionsCalculees > 0 {
            let formatTexteValeurEmissionsTotales = emissionsCalculees < 1000.0 ? NSLocalizedString("%.0f kg", comment: "") : emissionsCalculees < 100000.0 ? NSLocalizedString("%.1f t", comment: "") : NSLocalizedString("%.0f t", comment: "")
            let emissionsPourAffichage = emissionsCalculees >= 1000 ? emissionsCalculees / 1000.0 : emissionsCalculees
            texte.append(NSMutableAttributedString(string: String(format: NSLocalizedString("CO₂ : ", comment: "") + formatTexteValeurEmissionsTotales, emissionsPourAffichage), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTextePrincipal, weight: .regular)]))
            if effectif > 0 {
                if effectif != 1 {
                    if emissionsParPersonne >= 1000 {
                        texte.append(NSAttributedString(string: String(format: NSLocalizedString("\n%.1f t / personne\n", comment: ""), emissionsParPersonne / 1000.0), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSecondaire, weight: .regular)]))
                    } else {
                        texte.append(NSAttributedString(string: String(format: NSLocalizedString("\n%.0f kg / personne\n", comment: ""), emissionsParPersonne), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSecondaire, weight: .regular)]))
                        
                    }
                } else {
                    texte.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSecondaire, weight: .regular)]))
                }
                //
                let dureeEquivalenteSoutenableAns = emissionsParPersonne / emissionsSoutenablesAnnuelles
                let dureeEquivalenteSoutenableMois = dureeEquivalenteSoutenableAns * 12
                let dureeEquivalenteSoutenableJours = dureeEquivalenteSoutenableAns * 365
                let nomEvenement = lEvenement.texteCetEvenement
                var uniteDuree = ""
                var dureeEquivalenteSoutenable: Double = 0.0
                if dureeEquivalenteSoutenableJours <= 60 {
                    dureeEquivalenteSoutenable = dureeEquivalenteSoutenableJours
                    uniteDuree = NSLocalizedString("jours", comment: "")
                } else if dureeEquivalenteSoutenableMois < 24 {
                    dureeEquivalenteSoutenable = dureeEquivalenteSoutenableMois
                    uniteDuree = NSLocalizedString("mois", comment: "")
                } else {
                    dureeEquivalenteSoutenable = dureeEquivalenteSoutenableAns
                    uniteDuree = NSLocalizedString("ans", comment: "")
                }
                texte.append(NSAttributedString(string: String(format: NSLocalizedString("En %.0f jours, ", comment: "") + nomEvenement + NSLocalizedString(" produit autant que %.0f ", comment: "") + uniteDuree + NSLocalizedString(" d'émissions acceptables pour préserver le climat", comment: ""), typesEmissions[lEvenement.numeroItemDuree].valeur, dureeEquivalenteSoutenable), attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite, weight: .regular)]))
                let ratio = emissionsParPersonne == 0 ? 0.0 : emissionsParPersonne / emissionsSoutenables
                couleur = couleurSoutenabilite(ratioSoutenabilite: ratio)
            } else {
                if #available(iOS 13.0, *) {
                    couleur = .label
                } else {
                    // Fallback on earlier versions
                    couleur = .black
                }
                texte.addAttributes([NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize * tailleTextePrincipal, weight: .regular)], range: NSRange(location: 0, length: texte.length))
            }
            texte.addAttributes([NSAttributedString.Key.foregroundColor : couleur], range: NSRange(location: 0, length: texte.length))
            return NSAttributedString(attributedString: texte) //
        } else {
            if #available(iOS 13.0, *) {
                couleur = .label
            } else {
                // Fallback on earlier versions
                couleur = .black
            }
            return NSAttributedString(string: lEvenement.texteIndiquezCaracteristiques, attributes: [NSAttributedString.Key.foregroundColor: couleur, NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite)])

        }
    }
    
    
    func texteListeEmissions(lesEmissions: [TypeEmission], pourTexteBrut: Bool) -> NSAttributedString {
        let facteurPoliceTitre = 1.5
        let facteurPoliceSousTitre = 1.0
        let facteurPoliceTexte = 0.8
        let paragraphStyleCentre: NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyleCentre.alignment = NSTextAlignment.center
        paragraphStyleCentre.lineBreakMode = NSLineBreakMode.byWordWrapping
        let contenu = pourTexteBrut ? "" : (lEvenement.texteEmissionsDeMonEvenement) + "\n"
        let texte = NSMutableAttributedString(string: contenu, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTitre), NSAttributedString.Key.paragraphStyle: paragraphStyleCentre])

        var categorie = ""
        for emission in lesEmissions {
            if emission.valeur > 0 {
                if emission.categorie != categorie {
                    categorie = emission.categorie
                    texte.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))
                    texte.append(NSAttributedString(string: categorie + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre)]))
                }
                var texteLigneEmission = emission.emission < 2.0 ? NSLocalizedString(", %.0f g CO₂ ", comment: "") : emission.emission < 2000.0 ? NSLocalizedString(", %.0f kg CO₂ ", comment: "") : NSLocalizedString(", %.2f t CO₂ ", comment: "")

                let facteurValeurEmission = emission.emission < 2.0 ? 0.001 : emission.emission < 2000.0 ? 1.0 : 1000.0
                let pourcentage = emission.emission / emissionsCalculees * 100.0
                let texteFormatPourcentage = pourcentage < 0.5 ? NSLocalizedString("(< 1%%)\n", comment: "") : NSLocalizedString("(%.0f%%)\n", comment: "")
                texteLigneEmission.append(texteFormatPourcentage)

                texte.append(NSAttributedString(string: texteNomValeurUnite(emission: emission), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))
                if emission.facteurEmission > 0 {
                    texte.append(NSAttributedString(string: String(format: texteLigneEmission, emission.emission / facteurValeurEmission, pourcentage), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))
                } else {
                    texte.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))
                }
            }
        }
        let texteTotalEmissions = emissionsCalculees < 2000.0 ? NSLocalizedString("\nTotal : %.0f kg CO₂", comment: "") : NSLocalizedString("\nTotal : %.2f t CO₂", comment: "")
        let facteurTotalEmissions = emissionsCalculees < 2000.0 ? 1.0 : 1000.0
            texte.append(NSAttributedString(string: String(format: texteTotalEmissions, emissionsCalculees / facteurTotalEmissions), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre)]))
        let effectif = lEvenement.numeroItemEffectif >= 0 ? lesEmissions[lEvenement.numeroItemEffectif].valeur : 1.0
        let emissionsParPersonne = emissionsCalculees / effectif
        if effectif > 0.0 {
            var texteEmissionsParPersonne = "\n"
            if effectif != 1.0 {
                texteEmissionsParPersonne = emissionsParPersonne < 2000 ? NSLocalizedString(" (%.1f kg / personne)\n", comment: "") : NSLocalizedString(" (%.1f t / personne)\n", comment: "")
            }
            let facteurEmissionsParPersonne = emissionsParPersonne < 2000.0 ? 1.0 : 1000.0
            texte.append(NSAttributedString(string: String(format: texteEmissionsParPersonne, emissionsParPersonne / facteurEmissionsParPersonne), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre, weight: .regular)]))
            let dureeEquivalenteSoutenableAns = emissionsParPersonne / emissionsSoutenablesAnnuelles
            let dureeEquivalenteSoutenableMois = dureeEquivalenteSoutenableAns * 12
            let dureeEquivalenteSoutenableJours = dureeEquivalenteSoutenableAns * 365
            let ratio = emissionsParPersonne == 0 ? 0.0 : emissionsParPersonne / emissionsSoutenables
            let couleur = couleurSoutenabilite(ratioSoutenabilite: ratio)
            let nomEvenement = lEvenement.texteCetEvenement
            var uniteDuree = ""
            var dureeEquivalenteSoutenable: Double = 0.0
                if dureeEquivalenteSoutenableJours <= 60 {
                    dureeEquivalenteSoutenable = dureeEquivalenteSoutenableJours
                    uniteDuree = NSLocalizedString("jours", comment: "")
                } else if dureeEquivalenteSoutenableMois < 24 {
                    dureeEquivalenteSoutenable = dureeEquivalenteSoutenableMois
                    uniteDuree = NSLocalizedString("mois", comment: "")
                } else {
                    dureeEquivalenteSoutenable = dureeEquivalenteSoutenableAns
                    uniteDuree = NSLocalizedString("ans", comment: "")
                }
            
            texte.append(NSAttributedString(string: String(format: NSLocalizedString("En %.0f jours, ", comment: "") + nomEvenement + NSLocalizedString(" produit autant de gaz à effet de serre que %.0f ", comment: "") + uniteDuree + NSLocalizedString(" d'émissions acceptables pour préserver le climat", comment: ""), lesEmissions[lEvenement.numeroItemDuree].valeur, dureeEquivalenteSoutenable), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceSousTitre, weight: .regular), NSAttributedString.Key.foregroundColor : couleur]))
            texte.append(NSAttributedString(string: lEvenement.texteAnalysezReduisez, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * facteurPoliceTexte)]))
            let nomApp = lEvenement.texteNomApp
            let lienAppSotre = lEvenement.texteLienAppStore
                texte.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: (texte.string as NSString).range(of: nomApp))
                texte.addAttribute(.link, value: lienAppSotre, range: (texte.string as NSString).range(of: nomApp))
                if pourTexteBrut {
                    texte.append(NSAttributedString(string: NSLocalizedString(" : ", comment: "") + lienAppSotre))
                }
        }
        return texte
    }
}
