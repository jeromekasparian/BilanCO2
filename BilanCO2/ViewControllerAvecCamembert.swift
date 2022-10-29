//
//  ViewControllerAvecCamembert.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 19/09/2022.
//

import Foundation
import UIKit

let texteAfficherExplicationsFigures = "afficheExplicationFigures"

class ViewControllerAvecCamembert: UIViewController {
    @IBOutlet var affichageEmissions: UILabel!
//    @IBOutlet var affichageEmissionsParPersonne: UILabel!
//    @IBOutlet var affichageEmissionsSoutenables: UILabel!
    @IBOutlet var camembert: UIView!
    @IBOutlet var boutonAideGraphique: UIButton!
    @IBOutlet var boutonExport: UIButton!

    @IBOutlet var contrainteAffichageEmissionsDroitePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsDroitePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsBasPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsBasPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionHauteurPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertGauchePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertGauchePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertHautPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertCentreHPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertCentreVPaysage: NSLayoutConstraint!

    var orientationResultats: Orientation = .inconnu
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boutonAideGraphique.setTitle("", for: .normal)
        boutonExport.setTitle("", for: .normal)
//        if #available(iOS 13.0, *) {
//            affichageEmissions.backgroundColor = .systemBackground.withAlphaComponent(0.3)
//        } else {
//            affichageEmissions.backgroundColor = .white.withAlphaComponent(0.3)
//        }
    }
    func choisitContraintes(size: CGSize) -> Bool {
        let nouvelleOrientation: Orientation = size.width <= size.height ? .portrait : .paysage
        if nouvelleOrientation != orientationResultats {
            orientationResultats = nouvelleOrientation
            let estModePortrait = nouvelleOrientation == .portrait
//            print("choisitContraintes width height portrait", size.width, size.height, estModePortrait)
            self.contrainteAffichageEmissionsDroitePortrait.isActive = estModePortrait
            self.contrainteAffichageEmissionsDroitePaysage.isActive = !estModePortrait
            self.contrainteAffichageEmissionsBasPortrait.isActive = estModePortrait
            self.contrainteAffichageEmissionsBasPaysage.isActive = !estModePortrait
            self.contrainteAffichageEmissionHauteurPortrait.isActive = estModePortrait
            
            self.contrainteCamembertHautPaysage.isActive = !estModePortrait
            self.contrainteCamembertCentreHPortrait.isActive = estModePortrait
            self.contrainteCamembertGauchePortrait.isActive = estModePortrait
            self.contrainteCamembertGauchePaysage.isActive = !estModePortrait
            self.contrainteCamembertCentreVPaysage.isActive = !estModePortrait
            self.affichageEmissions.textAlignment = estModePortrait ? .center : .left
            return true
        }
        else {return false}
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
    
    
    func dessineCamembert(camembert: UIView, grandFormat: Bool) {
        // effacer le camembert existant
//        print("sublayers", camembert.layer.sublayers)
        if camembert.layer.sublayers == nil {
            print("sublayers nil")
        } else {
//            print ("nombre de sous couches", camembert.layer.sublayers?.count)
            //        if (camembert.layer.sublayers?.isEmpty ?? true) {
            camembert.layer.sublayers?.forEach({
//                print("layer", $0)
                $0.removeFromSuperlayer()
            })
        }
        var debut: CGFloat = 0.0
        let referenceRayon = max(emissionsCalculees, emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur)
//                print(emissionsCalculees, emissionsSoutenables, emissionsCalculees / referenceRayon)
        var camembertVide: Bool = true
        let rayon = min(camembert.frame.width, camembert.frame.height) / 2 * 0.9 * sqrt(emissionsCalculees / referenceRayon)
        let frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height) //camembert.frame //CGRect(x: 50, y: 100, width: 200, height: 200)
        var couleurSeparation = UIColor.black
        if #available(iOS 13.0, *) {
            couleurSeparation = .label
        }
        for emission in lesEmissions {
            if emission.emission > 0 {
                camembertVide = false
                let intervalle = emission.emission / emissionsCalculees
                let numeroSection = lesSections.firstIndex(where: {$0 == emission.categorie}) ?? 0
                dessineSecteur(rect: frame, rayon: rayon, debut: debut, etendue: intervalle, epaisseurTrait: rayon, couleurSecteur: couleursEEUdF6[numeroSection])
                
//                let graphique = Graphique()
//                graphique.radius = rayon
////                print(graphique.radius)
//                graphique.trackWidth = graphique.radius // min(graphique.frame.width, graphique.frame.height) / 8.0
//                graphique.startPoint = debut
//                let intervalle = emission.emission / emissionsCalculees
//                graphique.fillPercentage = intervalle
//                let numeroSection = lesSections.firstIndex(where: {$0 == emission.categorie}) ?? 0
//                graphique.color = couleursEEUdF6[numeroSection] //UIColor(morgenStemningNumber: numeroSection, MorgenStemningScaleSize: lesSections.count)
//                graphique.draw(frame) //, debut: 0, etendue: 0.9)
//                camembert.addSubview(graphique)
                debut = debut + intervalle
//
//                // trace d'une séparation entre les secteurs
                
                dessineSecteur(rect: frame, rayon: rayon, debut: debut - 0.0025, etendue: 0.005, epaisseurTrait: rayon, couleurSecteur: couleurSeparation)

                
//                let graphique2 = Graphique()
////                graphique2.frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height) //camembert.frame //CGRect(x: 50, y: 100, width: 200, height: 200)
//                graphique2.radius = rayon
////                print(graphique2.radius)
//                graphique2.trackWidth = graphique2.radius // min(graphique.frame.width, graphique.frame.height) / 8.0
//                graphique2.startPoint = debut - 0.0025
//                graphique2.fillPercentage = 0.005
//                if #available(iOS 13.0, *) {
//                    graphique2.color = .label
//                } else {
//                    graphique2.color = .black
//                }
//                graphique2.draw(frame) //, debut: 0, etendue: 0.9)
//                camembert.addSubview(graphique2)
            } // if emission.valeur > 0
        } // for
        

        // la référence de soutenabilité
        if !camembertVide {
            let rayonCercleVert = min(frame.width, frame.height) / 2 * 0.9 * sqrt(emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur / referenceRayon)
            dessineSecteur(rect: frame, rayon: rayonCercleVert, debut: 0.0, etendue: 1.0, epaisseurTrait: min(frame.width, frame.height) / 50.0, couleurSecteur: .green.withAlphaComponent(0.8))

//            let graphique = Graphique()
////            graphique.frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height)
////            print(graphique.radius)
//            graphique.trackWidth = min(graphique.frame.width, graphique.frame.height) / 50.0
//            graphique.startPoint = 0.0
//            graphique.fillPercentage = 1.0
//            graphique.color = .green.withAlphaComponent(0.8)
//            graphique.draw(frame) //, debut: 0, etendue: 0.9)
//            camembert.addSubview(graphique)
        
        // écrire la légende des éléments principaux dans le camembert
        let emissionsClassees = lesEmissions.sorted(by: {$0.emission > $1.emission}).filter({$0.emission > 0})
        let nombreMaxiLabels = afficherPictos ? (grandFormat ? 12 : 8) : 5
        let limite = emissionsClassees.isEmpty ? 0.0 : emissionsClassees.count >= nombreMaxiLabels ? emissionsClassees[nombreMaxiLabels - 1].emission : emissionsClassees.last?.emission ?? 0.0 // on affiche les 4 postes d'émission les plus importants, à condition qu'ils soient non-nuls
        let pourcentageMini = grandFormat ? 0.03 : 0.05
        if limite > 0 {
            debut = 0.0
            for emission in lesEmissions {
                let intervalle = emission.emission / emissionsCalculees
                if emission.emission >= limite && intervalle > pourcentageMini { // on n'affiche le nom des émissions que si elles sont au moins 5% du total, et seulement les 5 principales
                    let largeurLabel = rayon / 1.8
//                        let largeurLabel = afficherPictos ? camembert.frame.width / 5 : camembert.frame.width / 3
                    let hauteurLabel = afficherPictos ? largeurLabel * 0.5 : largeurLabel / 4
//                    let hauteurLabel = UIFont.systemFontSize * 1.5
                    let positionAngulaireLabel = Double (2 * .pi * (debut + (intervalle / 2.0) - 0.25))
                    let positionX = CGFloat(camembert.frame.width + rayon * cos(positionAngulaireLabel) * 1.5 - largeurLabel) / 2.0
                    let positionY = CGFloat(camembert.frame.height + rayon * sin(positionAngulaireLabel) * 1.5 - hauteurLabel) / 2.0
                    let texte = UILabel(frame: CGRect(x: positionX, y: positionY, width: largeurLabel, height: hauteurLabel))
                    texte.numberOfLines = 1
                    texte.textAlignment = .center
                    texte.minimumScaleFactor = 0.2
                    texte.lineBreakMode = .byTruncatingTail
                    if afficherPictos && !emission.picto.isEmpty {
                        texte.font = .systemFont(ofSize: hauteurLabel)
                        texte.text = emission.picto
                    } else {
                        texte.adjustsFontSizeToFitWidth = true
                        texte.font = .systemFont(ofSize: largeurLabel / 4)
                        texte.text = emission.nomCourt
                    }
                    camembert.addSubview(texte)
                }
                debut = debut + intervalle
            }
        }
        }
    }
    
    @IBAction func afficheExplicationsFigure() {
        ligneExplicationsSelectionnee = 1
        performSegue(withIdentifier: "Explications", sender: nil)
//        let message = "Ce graphique représente la répartition des émisssions de gaz à effet de serre dues au camp. Le cercle vert permet de les comparer avec les émissions acceptables pour préserver le climat : elles correspondent à 6,8 kg équivalent CO₂ par personne et par jour de camp."
//        let alerte = UIAlertController(title: "Pour en savoir plus", message: message, preferredStyle: .alert)
//        alerte.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "bouton OK"), style: .default, handler: nil))
//        self.present(alerte, animated: true)
    }

    
    @objc func actualiseAffichageEmissions(grandFormat: Bool) {
        DispatchQueue.main.async{
            self.affichageEmissions.attributedText = self.texteEmissions(typesEmissions: lesEmissions, grandFormat: grandFormat)  //  NSAttributedString(string:"Indiquez les caractéristiques de votre camp pour évaluer ses émissions de gaz à effet de serre")
        }
    }

    func texteEmissions(typesEmissions: [TypeEmission], grandFormat: Bool) -> NSAttributedString { //}(String, UIColor) {
//        print("espace dispo pour texte largeur hauteur ", affichageEmissions.frame.width, affichageEmissions.frame.height, "camembert l h", camembert.frame.width, camembert.frame.height)
//        let facteurTailleTexte = sqrt(pow(affichageEmissions.frame.width, 2.0) + pow(affichageEmissions.frame.height, 2.0)) / 200.0

        let emissionsParPersonne = emissionsCalculees / typesEmissions[SorteEmission.effectif.rawValue].valeur
        var couleur: UIColor = .black
        let texte = NSMutableAttributedString(string: "")
        if typesEmissions[SorteEmission.effectif.rawValue].valeur > 0 && !emissionsCalculees.isNaN && emissionsCalculees > 0 {
            if !boutonExport.isEnabled {boutonExport.isEnabled = true}
            let tailleTextePrincipal: CGFloat =  max(0.5, 3.0 * sqrt(affichageEmissions.frame.width * affichageEmissions.frame.height) / 200.0)  //grandFormat ? 3 : 2
            let tailleTexteSecondaire = 0.75 * tailleTextePrincipal
            let tailleTexteSoutenabilite = 0.75 * tailleTexteSecondaire

            let formatTexteValeurEmissionsTotales = emissionsCalculees >= 1000.0 ? "%.1f t" : "%.0f kg"
            let emissionsPourAffichage = emissionsCalculees >= 1000 ? emissionsCalculees / 1000.0 : emissionsCalculees
            texte.append(NSMutableAttributedString(string: String(format: "CO₂ : " + formatTexteValeurEmissionsTotales, emissionsPourAffichage), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * tailleTextePrincipal)]))
            if emissionsParPersonne >= 1000 {
                texte.append(NSAttributedString(string: String(format:"\n%.1f t / personne\n", emissionsParPersonne / 1000.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * tailleTexteSecondaire)]))
            } else {
                texte.append(NSAttributedString(string: String(format:"\n%.0f kg / personne\n", emissionsParPersonne), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * tailleTexteSecondaire)]))

            }
//
            let dureeEquivalenteSoutenableAns = emissionsParPersonne / emissionsSoutenablesAnnuelles
            let dureeEquivalenteSoutenableMois = dureeEquivalenteSoutenableAns * 12
            let dureeEquivalenteSoutenableJours = dureeEquivalenteSoutenableAns * 365
            if dureeEquivalenteSoutenableJours <= 60 {
                texte.append(NSAttributedString(string: String(format: "En %.0f jours, ce camp produit autant que %.0f jours d'émissions acceptables pour préserver le climat", typesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableJours), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite)]))
            } else if dureeEquivalenteSoutenableMois < 24 {
                texte.append(NSAttributedString(string: String(format: "En %.0f jours, ce camp produit autant que %.0f mois d'émissions acceptables pour préserver le climat", typesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableMois), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite)]))
            } else {
                texte.append(NSAttributedString(string: String(format: "En %.0f jours, ce camp produit autant que %.0f ans d'émissions acceptables pour préserver le climat", typesEmissions[SorteEmission.duree.rawValue].valeur, dureeEquivalenteSoutenableAns), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * tailleTexteSoutenabilite)]))
            }
                let ratio = emissionsParPersonne == 0 ? 0.0 : emissionsParPersonne / emissionsSoutenables
//                if ratio <= 1 {
//                    texte.append(NSAttributedString(string: String(format: "%.0f%% des émissions soutenables\n", ratio * 100.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
//                } else if ratio <= 2 {
//                    texte.append(NSAttributedString(string: String(format: "%.1f x les émissions soutenables\n", ratio), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
//                } else {
//                    texte.append(NSAttributedString(string: String(format: "%.0f x les émissions soutenables\n", ratio), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
//                }
                if ratio < 0.8 {couleur = vert2}
                else if ratio < 1.2 {couleur = orange}
                else {couleur = rougeVif}
//            if emissionsParPersonne > 0.3 * emissionsSoutenablesAnnuelles {
//                let ratioAnnuel = emissionsParPersonne / emissionsSoutenablesAnnuelles
//                if ratioAnnuel <= 1 {
//                    texte.append(NSAttributedString(string: String(format: "%.0f mois d'émissions soutenables", round(ratioAnnuel * 12)), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
//                } else if ratioAnnuel <= 2 {
//                    texte.append(NSAttributedString(string: String(format: "%.1f ans d'émissions soutenables", ratioAnnuel), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
//                } else {
//                    texte.append(NSAttributedString(string: String(format: "%.0f ans d'émissions soutenables", ratioAnnuel), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
//                }
//                couleur = rougeVif
//            }
            texte.addAttributes([NSAttributedString.Key.foregroundColor : couleur], range: NSRange(location: 0, length: texte.length))
//            print(texte.string)
            return NSAttributedString(attributedString: texte) //
//            return NSAttributedString(string: "TOTO") //
        } else {
            if boutonExport.isEnabled {boutonExport.isEnabled = false}
            return NSAttributedString(string:"Indiquez les caractéristiques de votre camp pour évaluer ses émissions de gaz à effet de serre", attributes: [NSAttributedString.Key.foregroundColor: couleur])
//            return NSAttributedString(string:String(format: "Émissions : %.0f kg eq. CO₂", emissionsCalculees), attributes: [NSAttributedString.Key.foregroundColor: couleur])
        }
//            return NSAttributedString(string: "")
    }

// https://stackoverflow.com/questions/5443166/how-to-convert-uiview-to-pdf-within-ios
    @IBAction func exportAsPdfFromView(sender: UIButton) {
        self.boutonExport.isHidden = true
        self.boutonAideGraphique.isHidden = true
        let vueAExporter = sender.superview ?? self.view!
        let pdfPageFrame = vueAExporter.bounds
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        vueAExporter.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        let path = URL(fileURLWithPath: NSTemporaryDirectory())
        let saveFileURL = path.appendingPathComponent("/CO2.pdf")
        do{
            try pdfData.write(to: saveFileURL)
        } catch {
            print("error-Grrr")
        }
        let activityViewController = UIActivityViewController(activityItems: [NSAttributedString(string: "Les émissions de CO₂ de mon camp", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 2)]), texteListeEmissions(lesEmissions: lesEmissions), saveFileURL], applicationActivities: nil) // "" : le corps du message intégré automatiquement
        #if targetEnvironment(macCatalyst)
        //"Don't do this !!"
        #else
        activityViewController.setValue("Impact climat de mon camp", forKey: "subject")
        #endif
        activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            if activity != nil {if activity!.rawValue == "com.apple.UIKit.activity.RemoteOpenInApplication-ByCopy"
                {
                    print("Coquinou")
                }
            }
        }
        if let popover = activityViewController.popoverPresentationController {
            popover.barButtonItem  = self.navigationItem.rightBarButtonItem
            popover.permittedArrowDirections = .up
            popover.sourceView = sender;
            popover.sourceRect = sender.frame;
        }
        present(activityViewController, animated: true, completion: {
            self.remettreBoutons()
        })
    }
    
    func remettreBoutons(){
        boutonExport.isHidden = false
        boutonAideGraphique.isHidden = false
    }
    
    func texteListeEmissions(lesEmissions: [TypeEmission]) -> NSAttributedString {
        let texte = NSMutableAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
        var categorie = ""
        for emission in lesEmissions {
            if emission.emission > 0 {
                if emission.categorie != categorie {
                    categorie = emission.categorie
                    texte.append(NSAttributedString(string: "\n" + categorie + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
                }
                let textePicto = afficherPictos && !emission.picto.isEmpty ? emission.picto + " " : ""
                if emission.emission < 2000.0 {
                    texte.append(NSAttributedString(string: textePicto + emission.nom + String(format: " : %.0f ", emission.valeur) + emission.unite + String(format: ", %.0f kg CO₂ (%.0f%%)\n", emission.emission, emission.emission / emissionsCalculees * 100.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.2)]))
                } else {
                    texte.append(NSAttributedString(string: textePicto + emission.nom + String(format: " : %.0f ", emission.valeur) + emission.unite + String(format: ", %.2f t CO₂ (%.0f%%)\n", emission.emission / 1000.0, emission.emission / emissionsCalculees * 100.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.2)]))
                }
            }
        }
        if emissionsCalculees < 2000.0 {
            texte.append(NSAttributedString(string: String(format: "\nTotal : %.0f kg CO₂", emissionsCalculees), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
        } else {
            texte.append(NSAttributedString(string: String(format: "\nTotal : %.2f t CO₂", emissionsCalculees / 1000), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
        }
        texte.append(NSAttributedString(string: "\n\nAnalysez et réduisez l'impact climatique de votre camp avec l'app ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
        texte.append(NSAttributedString(string: "Bilan CO2 camp scout", attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)]))        
        return texte
    }
}
