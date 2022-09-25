//
//  ViewControllerAvecCamembert.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 19/09/2022.
//

import Foundation
import UIKit

class ViewControllerAvecCamembert: UIViewController {
    @IBOutlet var affichageEmissions: UILabel!
    @IBOutlet var camembert: UIView!
    @IBOutlet var boutonAideGraphique: UIButton!

    @IBOutlet var contrainteAffichageEmissionsDroitePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsDroitePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsBasPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsBasPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertGauchePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertGauchePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertHautPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertCentreHPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertCentreVPaysage: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        boutonAideGraphique.setTitle("", for: .normal)
//        if #available(iOS 13.0, *) {
//            affichageEmissions.backgroundColor = .systemBackground.withAlphaComponent(0.3)
//        } else {
//            affichageEmissions.backgroundColor = .white.withAlphaComponent(0.3)
//        }
    }
    func choisitContraintes(size: CGSize){
        let estModePortrait = size.width <= size.height
//        print("choisitContraintes width height portrait", size.width, size.height, estModePortrait)
        self.contrainteAffichageEmissionsDroitePortrait.isActive = estModePortrait
        self.contrainteAffichageEmissionsDroitePaysage.isActive = !estModePortrait
        self.contrainteAffichageEmissionsBasPortrait.isActive = estModePortrait
        self.contrainteAffichageEmissionsBasPaysage.isActive = !estModePortrait

        self.contrainteCamembertHautPaysage.isActive = !estModePortrait
        self.contrainteCamembertCentreHPortrait.isActive = estModePortrait
        self.contrainteCamembertGauchePortrait.isActive = estModePortrait
        self.contrainteCamembertGauchePaysage.isActive = !estModePortrait
        self.contrainteCamembertCentreVPaysage.isActive = !estModePortrait
    }
    
    func dessineCamembert(camembert: UIView) {
        for subView in camembert.subviews {
            if subView is Graphique || subView is UILabel {
                subView.removeFromSuperview()
            }
        }
        var debut: CGFloat = 0.0
        let referenceRayon = max(emissionsCalculees, emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur)
        //        print(emissionsCalculees, emissionsSoutenables, emissionsCalculees / referenceRayon)
        var camembertVide: Bool = true
        let rayon = min(camembert.frame.width, camembert.frame.height) / 2 * 0.9 * sqrt(emissionsCalculees / referenceRayon)
        for emission in lesEmissions {
            if emission.valeur > 0 {
                camembertVide = false
                let graphique = Graphique()
                graphique.frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height) //camembert.frame //CGRect(x: 50, y: 100, width: 200, height: 200)
                graphique.radius = rayon
                print(graphique.radius)
                graphique.trackWidth = graphique.radius // min(graphique.frame.width, graphique.frame.height) / 8.0
                graphique.startPoint = debut
                let intervalle = emission.emission / emissionsCalculees
                graphique.fillPercentage = intervalle
                let numeroSection = lesSections.firstIndex(where: {$0 == emission.categorie}) ?? 0
                graphique.color = couleursEEUdF6[numeroSection] //UIColor(morgenStemningNumber: numeroSection, MorgenStemningScaleSize: lesSections.count)
                graphique.draw(graphique.frame) //, debut: 0, etendue: 0.9)
                camembert.addSubview(graphique)
                debut = debut + intervalle

                // trace d'une séparation entre les secteurs
                let graphique2 = Graphique()
                graphique2.frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height) //camembert.frame //CGRect(x: 50, y: 100, width: 200, height: 200)
                graphique2.radius = rayon
                print(graphique2.radius)
                graphique2.trackWidth = graphique2.radius // min(graphique.frame.width, graphique.frame.height) / 8.0
                graphique2.startPoint = debut - 0.0025
                graphique2.fillPercentage = 0.005
                if #available(iOS 13.0, *) {
                    graphique2.color = .label
                } else {
                    graphique2.color = .black
                }
                graphique2.draw(graphique2.frame) //, debut: 0, etendue: 0.9)
                camembert.addSubview(graphique2)
            } // if emission.valeur > 0
        } // for
        

        // la référence de soutenabilité
        if !camembertVide {
            let graphique = Graphique()
            graphique.frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height) 
            graphique.radius = min(graphique.frame.width, graphique.frame.height) / 2 * 0.9 * sqrt(emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur / referenceRayon)
            print(graphique.radius)
            graphique.trackWidth = min(graphique.frame.width, graphique.frame.height) / 50.0
            graphique.startPoint = 0.0
            graphique.fillPercentage = 1.0
            graphique.color = .green.withAlphaComponent(0.8)
            graphique.draw(graphique.frame) //, debut: 0, etendue: 0.9)
            camembert.addSubview(graphique)
        }
        
        // écrire la légende des éléments principaux dans le camembert
        let emissionsClassees = lesEmissions.sorted(by: {$0.emission > $1.emission}).filter({$0.emission > 0})
        let limite = emissionsClassees.isEmpty ? 0.0 : emissionsClassees.count >= 5 ? emissionsClassees[4].emission : emissionsClassees.last?.emission ?? 0.0 // on affiche les 4 postes d'émission les plus importants, à condition qu'ils soient non-nuls
        if limite > 0 {
            debut = 0.0
            for emission in lesEmissions {
                let intervalle = emission.emission / emissionsCalculees
                if emission.emission >= limite && intervalle > 0.05 { // on n'affiche le nom des émissions que si elles sont au moins 5% du total, et seulement les 5 principales
                    let largeurLabel = camembert.frame.width / 3
                    let hauteurLabel = largeurLabel / 4.5 // UIFont.systemFontSize
                    let positionAngulaireLabel = Double (2 * .pi * (debut + (intervalle / 2.0) - 0.25))
                    let positionX = CGFloat(camembert.frame.width + rayon * cos(positionAngulaireLabel) * 1.5 - largeurLabel) / 2.0
                    let positionY = CGFloat(camembert.frame.height + rayon * sin(positionAngulaireLabel) * 1.5 - hauteurLabel) / 2.0
                    let texte = UILabel(frame: CGRect(x: positionX, y: positionY, width: largeurLabel, height: hauteurLabel))
                    texte.numberOfLines = 1
                    texte.adjustsFontSizeToFitWidth = true
                    texte.textAlignment = .center
                    texte.text = emission.nomCourt
                    camembert.addSubview(texte)
                }
                debut = debut + intervalle
            }
        }
        
    }
    
    @IBAction func afficheExplicationsFigure() {
        let message = "Ce graphique représente la répartition des émisssions du camp. Le cercle vert permet de les comparer avec les émissions soutenables, soit l'équivalent de 2,5 tonnes équivalent CO2 par personne et par an, rapportées à la durée du camp."
        let alerte = UIAlertController(title: "Pour en savoir plus", message: message, preferredStyle: .alert)
        alerte.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "bouton OK"), style: .default, handler: nil))
        self.present(alerte, animated: true)
    }

    
    @objc func actualiseAffichageEmissions() {
        //        print("affichage")
        DispatchQueue.main.async{
            self.affichageEmissions.attributedText = self.texteEmissions(typesEmissions: lesEmissions)
//            let (texte, couleur) = self.texteEmissions(typesEmissions: lesEmissions)
//            self.affichageEmissions.text = texte
//            self.affichageEmissions.textColor = couleur
        }
    }

    func texteEmissions(typesEmissions: [TypeEmission]) -> NSAttributedString { //}(String, UIColor) {
        emissionsSoutenables = emissionsSoutenablesAnnuelles / 365 * typesEmissions[SorteEmission.effectif.rawValue].valeur // kg eq CO2 par personne
        let emissionsParPersonne = emissionsCalculees / typesEmissions[SorteEmission.effectif.rawValue].valeur
        var couleur: UIColor = .black
        let texte = NSMutableAttributedString(string: "")
        if typesEmissions[SorteEmission.effectif.rawValue].valeur > 0 && !emissionsCalculees.isNaN && emissionsCalculees > 0 {

            let formatTexteValeurEmissionsTotales = emissionsCalculees >= 1000.0 ? "%.1f t" : "%.0f kg"
            let emissionsPourAffichage = emissionsCalculees >= 1000 ? emissionsCalculees / 1000.0 : emissionsCalculees
            texte.append(NSMutableAttributedString(string: String(format: "CO₂ : " + formatTexteValeurEmissionsTotales + "\n%.0f kg / personne\n", emissionsPourAffichage, emissionsParPersonne), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 2)]))
//
                let ratio = emissionsParPersonne == 0 ? 0.0 : emissionsParPersonne / emissionsSoutenables
                if ratio <= 1 {
                    texte.append(NSAttributedString(string: String(format: "%.0f%% des émissions soutenables\n", ratio * 100.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
                } else if ratio <= 2 {
                    texte.append(NSAttributedString(string: String(format: "%.1f x les émissions soutenables\n", ratio), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
                } else {
                    texte.append(NSAttributedString(string: String(format: "%.0f x les émissions soutenables\n", ratio), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)]))
                }
                if ratio < 0.8 {couleur = vert2}
                else if ratio < 1.2 {couleur = orange}
                else {couleur = rougeVif}
            if emissionsParPersonne > 0.3 * emissionsSoutenablesAnnuelles {
                let ratioAnnuel = emissionsParPersonne / emissionsSoutenablesAnnuelles
                if ratioAnnuel <= 1 {
                    texte.append(NSAttributedString(string: String(format: "%.0f%% des émissions soutenables annuelles", ratioAnnuel * 100.0), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                } else if ratioAnnuel <= 2 {
                    texte.append(NSAttributedString(string: String(format: "%.1f x les émissions soutenables annuelles", ratioAnnuel), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                } else {
                    texte.append(NSAttributedString(string: String(format: "%.0f x les émissions soutenables annuelles", ratioAnnuel), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize)]))
                }
                couleur = rougeVif
            }
            texte.addAttributes([NSAttributedString.Key.foregroundColor : couleur], range: NSRange(location: 0, length: texte.length))
            return NSAttributedString(attributedString: texte) //
        } else {
            return NSAttributedString(string:String(format: "Émissions : %.0f kg eq. CO2", emissionsCalculees), attributes: [NSAttributedString.Key.foregroundColor: couleur])
        }
//            return NSAttributedString(string: "")
    }

    
}
