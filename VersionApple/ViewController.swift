//
//  ViewController.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 04/09/2022.
//


import UIKit
//import AVFoundation

let largeurMiniGlissiere: CGFloat = 150
let emissionsSoutenablesAnnuelles: Double = 2000.0 // t eq. CO2 / an / personne
let facteurZoomGlissiere: Float = 10.0

let notificationBackground = "notificationBackground"
var emissionsCalculees: Double = .nan
var emissionsSoutenables: Double = .nan
var lesSections: [Section] = []
let userDefaults = UserDefaults.standard
var lesEmissions: [TypeEmission] = []
//var afficherPictos: Bool = true

enum Orientation {
    case inconnu
    case portrait
    case paysage
}

var ligneEnCours: Int = -1

class ViewController: ViewControllerAvecCamembert, UITableViewDelegate, UITableViewDataSource, CelluleEmissionDelegate, CelluleCreditsDelegate, CelluleVideDelegate, UIPopoverControllerDelegate {
    
    // UIPopoverPresentationControllerDelegate, ConseilDelegate
    
    let keyValeursUtilisateurs = "keyValeursUtilisateurs"
    
    let cellReuseIdentifier = "CelluleEmission"
    let cellReuseIdentifierCredits = "CelluleCredits"
    let cellReuseIdentifierVide = "CelluleVide"
    //    var celluleEnCours: CelluleEmission! = nil
    var compteurMouvementsGlissiere: Int = 0
    var minValueNonZoomee: Float = .nan
    var maxValueNonZoomee: Float = .nan
    var valeurPrecedente: Float = .nan
    var couleurDefautThumb: UIColor = .white
    var glissiereModeZoom: Bool = false
    
    
    @IBOutlet var tableViewEmissions: UITableView!
    @IBOutlet var boutonEffacerDonnees: UIButton!
    @IBOutlet var boutonExport: UIButton!
    @IBOutlet var stackViewPrincipal: UIStackView!
    
//    @IBOutlet var contrainteTableViewHautPortrait: NSLayoutConstraint!
//    @IBOutlet var contrainteTableViewHautPaysage: NSLayoutConstraint!
//    @IBOutlet var contrainteTableViewDroitePortrait: NSLayoutConstraint!
//    @IBOutlet var contrainteTableViewDroitePaysage: NSLayoutConstraint!
//    
//    @IBOutlet var contrainteVueResultatsGauchePortrait: NSLayoutConstraint!
//    @IBOutlet var contrainteVueResultatsBasPaysage: NSLayoutConstraint!
//    @IBOutlet var contrainteVueResultatGauchePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonEffacerLarge: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonExporterLarge: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonEffacerEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonExporterEtroit: NSLayoutConstraint!
        
    override func viewDidLoad() {
//        if #available(iOS 13, *) {
            boutonEffacerDonnees.setTitle("", for: .normal) // ⌫  "\u{0232B}"
//        } else {
//            boutonEffacerDonnees.setImage(, for: .normal)
//            boutonEffacerDonnees.setTitle("", for: .normal) // ⌫  "\u{0232B}"
//            boutonEffacerDonnees.setTitle("\u{0232B}", for: .normal) // ⌫  "\u{0232B}"
//        }
        boutonExport.setTitle("", for: .normal)
        
        _ = self.choisitContraintes(size: self.view.frame.size)
        (lesEmissions, lesSections) = lireFichier(nom: "DataInternational")
        let lesValeurs = userDefaults.value(forKey: keyValeursUtilisateurs) as? [Double] ?? []
        if !lesValeurs.isEmpty && lesValeurs.count == lesEmissions.count {
            for i in 0...lesValeurs.count - 1 {
                lesEmissions[i].valeur = lesValeurs[i]
            }
        }
        
        actualiseValeursMax()
        emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)
        boutonExport.isHidden = emissionsCalculees == 0
        boutonEffacerDonnees.isHidden = emissionsCalculees == 0
        tableViewEmissions.delegate = self
        tableViewEmissions.dataSource = self
        if #available(iOS 15.0, *) {
            tableViewEmissions.sectionHeaderTopPadding = 0
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionTapped))
        tableViewEmissions.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self as? UIGestureRecognizerDelegate
        
        super.viewDidLoad()
    }  // viewDidLoad
    
    @objc func sectionTapped(sender: UITapGestureRecognizer) {
        print("tap")
        if sender.view != nil {
            let tapLocation = sender.location(in: tableViewEmissions)
//            if let tapIndexPath = tableViewEmissions.indexPathForRow(at: tapLocation) {
//                if (tableViewEmissions.cellForRow(at: tapIndexPath)) != nil {
//                    // do something with the row
//                print("tapped on row at index: \(tapIndexPath.row)")
//                }
//            }  else {
                for i in 0..<tableViewEmissions.numberOfSections {
                    let sectionHeaderArea = tableViewEmissions.rectForHeader(inSection: i)
                    if sectionHeaderArea.contains(tapLocation) {
                        // do something with the section
                        print("tapped on section at index: \(i)")
                        if !lesSections[i].afficherLaSection || (lesSections[i].afficherLaSection && lesSections[i].emissionsSection == 0 && lesSections[i].optionnel) {
                            lesSections[i].afficherLaSection.toggle()
                            tableViewEmissions.reloadData()
                        }
                    }
                }
//            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.redessineResultats(size: self.view.frame.size, curseurActif: false)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lesSections.count
    }
    
    
    //// gestion des tableView
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        let nombreDeLignesDansLaSection = lesEmissions.filter({$0.categorie == lesSections[section]}).count
        //        let sectionOptionnelle = lesEmissions.filter({$0.categorie == lesSections[section]}).first?.sectionOptionnelle ?? false
        //        let afficherLaSection = !sectionOptionnelle || calculeEmissionsSection(section: section) > 0
        //        return afficherLaSection ? nombreDeLignesDansLaSection : 0
        return lesEmissions.filter({$0.categorie == lesSections[section].nom}).count
    }
    
    func numeroDeLigne(indexPath: IndexPath) -> Int {
        var compteur: Int = 0
        let nomDeSection = lesSections[indexPath.section].nom
        while lesEmissions[compteur].categorie != nomDeSection {compteur = compteur + 1}
        return compteur + indexPath.row
    }
    
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        //        print("Cell for row at index path \(indexPath)")
        if indexPath.section < lesSections.count - 1 {  // les vraies données
            if lesSections[indexPath.section].afficherLaSection {
                return creeCelluleNormale(tableView, cellForRowAt: indexPath)
            } else {
                return creeCelluleVide(tableView, cellForRowAt: indexPath)
            }
        } else {  // la dernière section : l'ours
            return creeCelluleCredits(tableView, cellForRowAt: indexPath)
        }
    }
    
    func creeCelluleCredits (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewEmissions.dequeueReusableCell(withIdentifier: cellReuseIdentifierCredits, for: indexPath) as! CelluleCredits
        cell.selectionStyle = .none
        cell.delegate = self
        cell.boutonOuvrirWeb.setTitle("", for: .normal)
        return cell
    }
    
    func creeCelluleVide (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewEmissions.dequeueReusableCell(withIdentifier: cellReuseIdentifierVide, for: indexPath) as! CelluleVide
        cell.selectionStyle = .none
        cell.backgroundColor = couleursEEUdF5[indexPath.section].withAlphaComponent(0.3) // UIColor(morgenStemningNumber: indexPath.section, MorgenStemningScaleSize: lesSections.count).withAlphaComponent(0.5)
        cell.delegate = self
        return cell
    }
    
    func creeCelluleNormale (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let emission = lesEmissions[numeroDeLigne(indexPath: indexPath)]
        let cell = tableViewEmissions.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CelluleEmission
        cell.delegate = self
        cell.selectionStyle = .none
        if emission.echelleLog {
            cell.glissiere.minimumValue = Float(2.3) // valeur minimum = 10 // Float(0.0) pour une valeur minimum de 1
            cell.glissiere.maximumValue = log(Float(emission.valeurMax))
            emission.valeur = max(emission.valeur, exp(Double(cell.glissiere.minimumValue)))
            cell.glissiere.value = log(Float(emission.valeur))
            if cell.glissiere.value == cell.glissiere.minimumValue {
                emission.valeur = 0.0
            }
        } else {
            cell.glissiere.minimumValue = 0.0 // emission.facteurEmission == 0 ? Float(1.0) : Float(0.0)
            cell.glissiere.maximumValue = Float(emission.valeurMax)
            emission.valeur = max(emission.valeur, Double(cell.glissiere.minimumValue))
            cell.glissiere.value = Float(emission.valeur)
        }
        cell.glissiere.thumbTintColor = couleurDefautThumb // attention si couleur différentes pour l'animation ?
        cell.glissiere.isContinuous = true  // pour que le slider reçoive des mises à jour même s'il ne bouge pas : comportement par défaut sur MacOS, mais pas sur iOS
        cell.labelNom.text = texteNomValeurUnite(emission: emission) //, afficherPictos: afficherPictos)
        cell.labelNom.font = .monospacedDigitSystemFont(ofSize: cell.labelNom.font.pointSize, weight: .regular)
        cell.labelValeur.isHidden = true // l'emplacement de la loupe qui indique le zoom
        cell.actualiseEmissionIndividuelle(typeEmission: emission)
        cell.labelEmissionIndividuelle.font = .monospacedDigitSystemFont(ofSize: cell.labelEmissionIndividuelle.font.pointSize, weight: .regular)
        cell.boutonInfo.isHidden = emission.conseil.isEmpty
        cell.backgroundColor = couleursEEUdF5[indexPath.section].withAlphaComponent(0.3) // UIColor(morgenStemningNumber: indexPath.section, MorgenStemningScaleSize: lesSections.count).withAlphaComponent(0.5)
        cell.boutonInfo.setTitle("\u{2007}", for: .normal)
        return cell
    }
    
    //    func calculeEmissionsSection(section: Int) -> Double {
    //        let titreSection = lesSections[section]
    //        let lesEmissionsDeLaSection = lesEmissions.filter({$0.categorie == titreSection}).map({$0.emission})
    //        return lesEmissionsDeLaSection.reduce(0.0, +)
    //    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var titreSection = lesSections[section].nom
        if lesSections[section].emissionsSection > 0 {
            titreSection = titreSection + String(format: " (%.0f %%)", lesSections[section].emissionsSection / emissionsCalculees * 100.0)
        }
        let margeVerticale = CGFloat(12.0)
        let margeHorizontale = CGFloat(20.0)
        let hauteurLabel = CGFloat(24.0)
        let headerView = UIView() //frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: hauteurLabel + 2 * margeVerticale))
        //        headerView.frame.size.height = hauteurLabel + 2 * margeVerticale
        headerView.backgroundColor = couleursEEUdF5[section] //UIColor(morgenStemningNumber: section, MorgenStemningScaleSize: lesSections.count) //.withAlphaComponent(0.7)
        let headerLabel = UILabel(frame: CGRect(x: margeHorizontale, y: margeVerticale, width: tableView.bounds.size.width - 2 * margeHorizontale, height: hauteurLabel))
        headerLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).withSize(21) //  .boldSystemFont(ofSize: 24) // UIFont(name: "Verdana", size: 20)
        var blanc: CGFloat = 0
        var alpha: CGFloat = 0
        couleursEEUdF5[section].getWhite(&blanc, alpha: &alpha)
        //        print("blanc \(blanc)")
        headerLabel.textColor = blanc > 0.5 ? .black : .white
        headerLabel.text = titreSection // self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.numberOfLines = 1
        headerLabel.adjustsFontSizeToFitWidth = true
        headerView.addSubview(headerLabel)
        
        //        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        //        tapRecognizer.numberOfTapsRequired = 1
        //        tapRecognizer.numberOfTouchesRequired = 1
        //        headerView.addGestureRecognizer(tapRecognizer)
        
        return headerView
    }
    
    //    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
    //        print("Tapped")
    //    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if lesSections[section].nom == "" {
            return CGFloat(0.0)
        } else {
            let headerHeight: CGFloat = 48
            if #available(iOS 11.0, *) {
                tableView.estimatedSectionHeaderHeight = headerHeight
                return UITableView.automaticDimension
            } else {
                return headerHeight
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectHeaderAt: Int) {
        print("sélectionné", didSelectHeaderAt)
    }
    
    func afficheConseil(cell: CelluleEmission){
        //        var message = ""
        if let indexPathDeLaCellule = tableViewEmissions.indexPath(for: cell) {
            let message = lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].conseil //  cell.labelConseil.text
            let nomsRessources = lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].nomsRessources
            let liensRessources = lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].liensRessources
            let alerte = UIAlertController(title: NSLocalizedString("Un conseil", comment: ""), message: message, preferredStyle: .alert)
            if !nomsRessources.isEmpty && !liensRessources.isEmpty {
                print("nom ressource : ", nomsRessources, "liens ressources", liensRessources)
                
                for i in 0...min(nomsRessources.count, liensRessources.count) - 1 {
                    alerte.addAction(UIAlertAction(title: nomsRessources[i], style: .default, handler: {_ in self.ouvrirWeb(adresse: liensRessources[i])}))
                }
            }
            alerte.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "bouton OK"), style: .default, handler: nil))
            self.present(alerte, animated: true)
        }
    }
    
    @IBAction func alerteConfirmationReset(){
        let alerte = UIAlertController(title: NSLocalizedString("Initialisation", comment: ""), message: NSLocalizedString("Effacer les données ?", comment: ""), preferredStyle: .alert)
        alerte.addAction(UIAlertAction(title: NSLocalizedString("Annuler", comment: ""), style: .default, handler: nil))
        alerte.addAction(UIAlertAction(title: NSLocalizedString("Effacer", comment: ""), style: .destructive, handler: {_ in self.effacerDonnees()}))
        self.present(alerte, animated: true)
    }
    
    
    func effacerDonnees() {
        for i in 0...lesEmissions.count - 1 {
            lesEmissions[i].valeur = 0.0 // lesEmissions[i].facteurEmission > 0 ? //0.0 : 1.0  // pour la durée et l'effectif, on met 1 par défaut, pas zéro
        }
        actualiseValeursMax()
        emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)
        boutonExport.isHidden = emissionsCalculees == 0
        boutonEffacerDonnees.isHidden = emissionsCalculees == 0
        //        print("emissions Calculées : ", emissionsCalculees)
        let lesValeurs = lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: keyValeursUtilisateurs)
        
        DispatchQueue.main.async {
            self.tableViewEmissions.reloadData()
            self.tableViewEmissions.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.actualiseAffichageEmissions()
            self.dessineCamembert(camembert: self.camembert, curseurActif: false, lesEmissions: lesEmissions, ligneActive: ligneEnCours)
        }
    }
    
    func debutMouvementGlissiere(cell: CelluleEmission){
        //        if celluleEnCours == nil {
        guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
            print("erreur index Path - debut mouvement glissière")
            return
        }
        //            compteurMouvementsGlissiere = compteurMouvementsGlissiere + 1
        //            premierAffichageApresInitialisation = false
        //            celluleEnCours = cell
        ligneEnCours = numeroDeLigne(indexPath: indexPath)
        minValueNonZoomee = cell.glissiere.minimumValue
        maxValueNonZoomee = cell.glissiere.maximumValue
        valeurPrecedente = cell.glissiere.value
        //            couleurDefautThumb = cell.glissiere.thumbTintColor ?? .white
        glissiereModeZoom = false
        //            compteurCurseurImmobile = 0
        //            ligneTimerEnCoursPourZoom = -1
        //        }
        lancerTimerZoom(cell: cell, ligne: ligneEnCours)
    }
    
    func lancerTimerZoom(cell: CelluleEmission, ligne: Int) {
        if !self.glissiereModeZoom && ((cell.glissiere.maximumValue - cell.glissiere.minimumValue) / facteurZoomGlissiere >= 3 || lesEmissions[ligne].echelleLog) {
            let valeur = cell.glissiere.value
            let compteurAuDebutDuTimer = self.compteurMouvementsGlissiere
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if compteurAuDebutDuTimer == self.compteurMouvementsGlissiere && abs(valeur - cell.glissiere.value) < 0.02 * (cell.glissiere.maximumValue - cell.glissiere.minimumValue) && !self.glissiereModeZoom {
                    //                    print("zoom", compteurAuDebutDuTimer, self.compteurMouvementsGlissiere, ligne)
                    self.activerModeZoomGlissiere(ligne: ligne, cellule: cell, echelleLog: lesEmissions[ligne].echelleLog)
                }
            }
        }
    }
    
    func glissiereBougee(cell: CelluleEmission) {
        guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
            print("erreur index Path - glissière bougée")
            return
        }
        //        if ligneEnCours >= 0 && celluleEnCours != nil {
        let ligne = numeroDeLigne(indexPath: indexPath)
        let emission = lesEmissions[ligne]
        //        print("glissiereBougee", cell.glissiere.value, ligne, emission.nom, compteurMouvementsGlissiere)
        lancerTimerZoom(cell: cell, ligne: ligne)
        self.valeurPrecedente = cell.glissiere.value
        if emission.echelleLog {
            if cell.glissiere.value == self.minValueNonZoomee { //  cellule!.glissiere.minimumValue {
                lesEmissions[ligne].valeur = 0.0
            } else {
                lesEmissions[ligne].valeur = arrondi(exp(Double(cell.glissiere.value)))
            }
        } else {
            lesEmissions[ligne].valeur = Double(cell.glissiere.value)
            if emission.valeurEntiere {
                lesEmissions[ligne].valeur = round(lesEmissions[ligne].valeur)
            }
        }
        self.ajusteQuantitesLiees(ligne: ligne)
        emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)
        cell.labelNom.text = texteNomValeurUnite(emission: lesEmissions[ligne]) //, afficherPictos: afficherPictos)
        DispatchQueue.main.async{
            self.boutonExport.isHidden = emissionsCalculees == 0
            self.boutonEffacerDonnees.isHidden = emissionsCalculees == 0
            cell.actualiseEmissionIndividuelle(typeEmission: lesEmissions[ligne])  // Bizarre, devrait être déjà inclus dans le reloadRows
            var lesIndexPathAActualiser: [IndexPath] = []
            if let indexPathAActualiser = self.tableViewEmissions.indexPathForSelectedRow {
                lesIndexPathAActualiser = [indexPathAActualiser]
                print(lesIndexPathAActualiser.count, "à actualiser")
            }
            self.tableViewEmissions.reloadRows(at: lesIndexPathAActualiser, with: .automatic)
            self.actualiseAffichageEmissions()
            self.dessineCamembert(camembert: self.camembert, curseurActif: true, lesEmissions: lesEmissions, ligneActive: ligneEnCours)
        }  // DispatchQueue.main.async
        //        } // if ligneEnCours >= 0 && celluleEnCours != nil
    }
    
    
    func finMouvementGlissiere(cell: CelluleEmission) {
        //        print("fin mouvement glissière")
        glissiereBougee(cell: cell)
        ligneEnCours = -1
        self.compteurMouvementsGlissiere = self.compteurMouvementsGlissiere + 1
        let lesValeurs = lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: keyValeursUtilisateurs)
        //        cell.glissiere.minimumValue = minValueNonZoomee
        //        cell.glissiere.maximumValue = maxValueNonZoomee
        //       self.celluleEnCours = nil
        //        ligneEnCours = -1
        //        glissiereModeZoom = false
        //        DispatchQueue.main.async{
        //            cell.glissiere.thumbTintColor = self.couleurDefautThumb
        //        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableViewEmissions.reloadData()
            self.dessineCamembert(camembert: self.camembert, curseurActif: false, lesEmissions: lesEmissions, ligneActive: ligneEnCours)
        }
    }
    
    func ajusteQuantitesLiees(ligne: Int) {
        switch ligne {
        case SorteEmission.duree.rawValue:
            ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
        case SorteEmission.repasViandeRouge.rawValue:
            ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
        case SorteEmission.repasViandeBlanche.rawValue:
            ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasViandeBlanche, priorite2: SorteEmission.repasViandeRouge, priorite3: SorteEmission.repasVegetarien)
        case SorteEmission.repasVegetarien.rawValue:
            ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasVegetarien, priorite2: SorteEmission.repasViandeRouge, priorite3: SorteEmission.repasViandeBlanche)
        case SorteEmission.effectif.rawValue:
            actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
        case SorteEmission.optimist.rawValue, SorteEmission.caravelle.rawValue, SorteEmission.deriveur.rawValue, SorteEmission.canot.rawValue, SorteEmission.zodiac.rawValue:
            actualiseValeurMaxBateaux()
        default: let dummy = 1
        }
        
    }
    
    
    func activerModeZoomGlissiere(ligne: Int, cellule: CelluleEmission, echelleLog: Bool) {
        let intervalleHaut = cellule.glissiere.maximumValue - cellule.glissiere.value
        let intervalleBas = cellule.glissiere.value - cellule.glissiere.minimumValue
        if echelleLog {
            cellule.glissiere.maximumValue = cellule.glissiere.value + (intervalleHaut / facteurZoomGlissiere)
            cellule.glissiere.minimumValue = cellule.glissiere.value - (intervalleBas / facteurZoomGlissiere)
        } else {
            cellule.glissiere.maximumValue = max(min(cellule.glissiere.maximumValue, cellule.glissiere.value + 1), cellule.glissiere.value + (intervalleHaut / facteurZoomGlissiere))
            cellule.glissiere.minimumValue = min(max(cellule.glissiere.minimumValue, cellule.glissiere.value - 1), cellule.glissiere.value - (intervalleBas / facteurZoomGlissiere))
        }
        cellule.glissiere.thumbTintColor = .gray
        self.glissiereModeZoom = true
        cellule.labelValeur.isHidden = false
    }
    
    //    func desactiverModeZoomGlissiere(ligne: Int, cellule: CelluleEmission) {
    //        cellule.glissiere.thumbTintColor = .white
    //        self.glissiereModeZoom = false
    //        cellule.glissiere.maximumValue = maxValueNonZoomee
    //        cellule.glissiere.minimumValue = minValueNonZoomee
    //    }
    
    
//    func dessineBoutons(ecranLarge: Bool){
//        let taille: CGFloat = ecranLarge ? 20 : 16
//        if #available(iOS 13.0, *) {
//            boutonExport.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: taille)), for: .normal)
//            boutonEffacerDonnees.setImage(UIImage(systemName: "delete.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: taille)), for: .normal)
//        } else {
//            boutonExport.setImage(UIImage(named: "square.and.arrow.up"), for: .normal) //, withConfiguration: UIImage.SymbolConfiguration(pointSize: taille)), for: .normal)
//           boutonEffacerDonnees.setImage(UIImage(named: "delete.left"), for: .normal) //, withConfiguration: UIImage.SymbolConfiguration(pointSize: taille)), for: .normal)
//        }
//    }
//    
    
    override func choisitContraintes(size: CGSize) -> Bool {
        //        print("choisitContraintes")
        let nouvelleOrientation: Orientation = size.width <= size.height ? .portrait : .paysage
        var change = false
        var change3 = false
        
        //        if nouvelleOrientation != orientationGlobale {
        //            let estModePortrait = nouvelleOrientation == .portrait
        //            orientationGlobale = nouvelleOrientation
        //            print("choisit contraintes, orientation", nouvelleOrientation)
        //            if estModePortrait {  // on désactive avant d'activer pour éviter les conflits
        if nouvelleOrientation == .portrait && self.stackViewPrincipal.axis != .vertical { //self.contrainteTableViewHautPaysage.isActive {
            self.stackViewPrincipal.axis = .vertical
//            self.contrainteTableViewHautPaysage.isActive = false
//            self.contrainteTableViewDroitePaysage.isActive = false
//            self.contrainteVueResultatsBasPaysage.isActive = false
//            self.contrainteVueResultatGauchePaysage.isActive = false
//            
//            self.contrainteTableViewHautPortrait.isActive = true
//            self.contrainteTableViewDroitePortrait.isActive = true
//            self.contrainteVueResultatsGauchePortrait.isActive = true
            change = true
        } else if nouvelleOrientation == .paysage && self.stackViewPrincipal.axis != .horizontal {  // self.contrainteTableViewHautPortrait.isActive {
            self.stackViewPrincipal.axis = .horizontal
//            self.contrainteTableViewHautPortrait.isActive = false
//            self.contrainteTableViewDroitePortrait.isActive = false
//            self.contrainteVueResultatsGauchePortrait.isActive = false
//            
//            self.contrainteTableViewHautPaysage.isActive = true
//            self.contrainteTableViewDroitePaysage.isActive = true
//            self.contrainteVueResultatsBasPaysage.isActive = true
//            self.contrainteVueResultatGauchePaysage.isActive = true
            change = true
        }
        //        }
//        let ecranLarge = self.vueResultats.frame.width >= 600
//        if ecranLarge && !self.contrainteLargeurBoutonEffacerLarge.isActive {  // réduire la taille des boutons si on a un écran étroit.
//            self.contrainteLargeurBoutonEffacerEtroit.isActive = false
//            self.contrainteLargeurBoutonExporterEtroit.isActive = false
//            self.contrainteLargeurBoutonEffacerLarge.isActive = true
//            self.contrainteLargeurBoutonExporterLarge.isActive = true
//            dessineBoutons(ecranLarge: ecranLarge)
//            change3 = true
//        } else if !ecranLarge && !self.contrainteLargeurBoutonEffacerEtroit.isActive {
//            self.contrainteLargeurBoutonEffacerLarge.isActive = false
//            self.contrainteLargeurBoutonExporterLarge.isActive = false
//            self.contrainteLargeurBoutonEffacerEtroit.isActive = true
//            self.contrainteLargeurBoutonExporterEtroit.isActive = true
//            dessineBoutons(ecranLarge: ecranLarge)
//            change3 = true
//        }
        //        print("largeurResultats", self.vueResultats.frame.width)
        let change2 = super.choisitContraintes(size: self.vueResultats.frame.size)
        return change || change2 || change3
    }
    
    @objc func ouvrirWeb(adresse: String) {
        if let url = URL(string: adresse), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func ouvrirWebEEUdF() {
        ouvrirWeb(adresse: NSLocalizedString("https://www.eeudf.org", comment: ""))
    }
    //        print("web")
    //        let adresse = NSLocalizedString("https://www.eeudf.org", comment: "")
    //
    //    }
    
    
    func redessineResultats(size: CGSize, curseurActif: Bool) {
        DispatchQueue.main.async {
            let delai = self.choisitContraintes(size: size) ? 0.01 : 0.00
            DispatchQueue.main.asyncAfter(deadline: .now() + delai) {
                self.actualiseAffichageEmissions()
                self.dessineCamembert(camembert: self.camembert, curseurActif: curseurActif, lesEmissions: lesEmissions, ligneActive: ligneEnCours)
            }
        }
        if ligneEnCours < 0 { // pour ne pas actualiser le tableView pendant qu'on manipule un curseur
            tableViewEmissions.reloadData()
        }
    }
    
    //    override func viewWillLayoutSubviews() {
    //        print("viewWillLayoutSubviews")
    //        let size = self.view.frame.size
    //        redessineResultats(size: size, curseurActif: false)
    //        super.viewWillLayoutSubviews()
    //    }
    
    override func viewDidLayoutSubviews() {
        //        print("viewDidLayoutSubviews")
        let size = self.view.frame.size
        redessineResultats(size: size, curseurActif: false)
        super.viewDidLayoutSubviews()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //        print("viewWillTransition")
        redessineResultats(size: size, curseurActif: false)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // https://stackoverflow.com/questions/5443166/how-to-convert-uiview-to-pdf-within-ios
    @IBAction func exportAsPdfFromView(sender: UIButton) {
        let leTexte = texteListeEmissions(lesEmissions: lesEmissions, pourTexteBrut: true).string
        var items: [Any] = [EmailSubjectActivityItemSource(subject: NSLocalizedString("Impact climat de mon camp", comment: ""), emailBody: leTexte)]
        if let urlPDFAExporter = generePDF() {
            print("pdf ok")
            items.append(urlPDFAExporter)
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil) // "" : le corps du message intégré automatiquement
            if let popover = activityViewController.popoverPresentationController {
                popover.barButtonItem  = self.navigationItem.rightBarButtonItem
                popover.permittedArrowDirections = .any
                popover.sourceView = sender // sender;
                //            popover.delegate = self
                //            popover.sourceRect = sender.frame //sender.frame;
            }
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    func generePDF() -> URL? {
        let url = Bundle.main.url(forResource: "PageBlanche", withExtension: "pdf")! as CFURL
        let originalPDF:CGPDFDocument=CGPDFDocument(url)!
        let saveFileURL = NSTemporaryDirectory().appending("CO2.pdf")
        guard UIGraphicsBeginPDFContextToFile(saveFileURL, CGRect.zero, nil) else {
            print("oups1", saveFileURL)
            return nil
        }
        guard let destContext = UIGraphicsGetCurrentContext() else {
            print("oups2")
            return nil
        }
        
        if let page = originalPDF.page(at: 1) {
            var mediaBox = page.getBoxRect(.mediaBox)
            destContext.beginPage(mediaBox: &mediaBox)
            destContext.drawPDFPage(page)
            destContext.textMatrix = .identity
            destContext.translateBy(x: 0, y: mediaBox.height)
            destContext.scaleBy(x: 1, y: -1)
            
            let marge: CGFloat = 40
            let largeurTexte = mediaBox.width - 2 * marge
            let textePourPdf1 = texteListeEmissions(lesEmissions: lesEmissions, pourTexteBrut: false)
            let hauteurTexte1 = textePourPdf1.hauteur(largeur: largeurTexte)
            let box1 = CGRect(x: mediaBox.minX + marge, y: mediaBox.minY + marge, width: largeurTexte, height: hauteurTexte1 + marge)
            textePourPdf1.draw(in: box1)
//            print(textePourPdf1)
            let hauteurMax2 = mediaBox.maxY - box1.maxY - marge
            let hauteurEtLargeur = min(hauteurMax2, largeurTexte)
            let box2 = CGRect(x: box1.minX + (largeurTexte - hauteurEtLargeur) / 2 , y: box1.maxY, width: hauteurEtLargeur, height: hauteurEtLargeur)
            camembert.asImage().draw(in: box2)
            if let imageQRCode = UIImage(named: "QRCodeAppStore") {
                let tailleQRCode: CGFloat = 50
                let box2b = CGRect(x: box1.maxX - tailleQRCode, y: box2.minY, width: tailleQRCode, height: tailleQRCode)
                imageQRCode.draw(in: box2b)
            }
            destContext.endPage()
        }
        destContext.closePDF()
        UIGraphicsEndPDFContext()
        return URL(fileURLWithPath: saveFileURL)
    }
    
    
    //    func formatAffichageValeur(valeurMax: Double) -> String {
    //        let nombreChiffresMax = valeurMax > 0 ? Int(ceil(log(valeurMax) / log(10.0) + 0.01)) : 1
    //        switch nombreChiffresMax {
    //        case 1: return "%1.0f"
    //        case 2: return "%2.0f"
    //        case 3: return "%3.0f"
    //        case 4: return "%4.0f"
    //        case 5: return "%5.0f"
    //        case 6: return "%6.0f"
    //        default: return "%.0f"
    //        }
    //    }
    //
    //    func texteValeurPourTableView(valeurMax: Double, unite: String, valeur: Double, afficherLoupe: Bool, tailleFonte: CGFloat) -> NSAttributedString {
    //        let alpha = afficherLoupe ? 1.0 : 0.0
    //        let couleurLoupe = UIColor.black.withAlphaComponent(alpha) // n'importe quelle couleur est ok en fait - du moins tant qu'on ne gère pas le mode sombre
    //        let texteAAfficher = NSMutableAttributedString(string: "🔎", attributes: [NSAttributedString.Key.foregroundColor: couleurLoupe])
    //        let texteValeurUnite =  NSAttributedString(string: String(format: self.formatAffichageValeur(valeurMax: valeurMax), valeur).replacingOccurrences(of: " ", with: "\u{2007}") + " " + unite, attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: tailleFonte, weight: .regular)])
    //        texteAAfficher.append(texteValeurUnite)
    //        return texteAAfficher as NSAttributedString
    //    }
    
}

extension NSAttributedString {
    func hauteur(largeur: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: largeur, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.attributedText = self
        label.sizeToFit()
        return label.frame.size.height
    }
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
