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
//var lesSections: [Section] = []
let userDefaults = UserDefaults.standard
//var lesEmissions: [TypeEmission] = []
//var afficherPictos: Bool = true

enum Orientation {
    case inconnu
    case portrait
    case paysage
}

var ligneEnCours: Int = -1

class ViewController: ViewControllerAvecCamembert, UITableViewDelegate, UITableViewDataSource, CelluleEmissionDelegate, CelluleCreditsDelegate, CelluleVideDelegate, UIPopoverControllerDelegate {
    
    let keyModeCongres = "keyModeCongres"
    let cellReuseIdentifier = "CelluleEmission"
    let cellReuseIdentifierCredits = "CelluleCredits"
    let cellReuseIdentifierVide = "CelluleVide"
    var compteurMouvementsGlissiere: Int = 0
    var minValueNonZoomee: Float = .nan
    var maxValueNonZoomee: Float = .nan
    var valeurPrecedente: Float = .nan
    var couleurDefautThumb: UIColor = .white
    var glissiereModeZoom: Bool = false
    var premierLancement: Bool = true

    
    @IBOutlet var tableViewEmissions: UITableView!
    @IBOutlet var boutonEffacerDonnees: UIButton!
    @IBOutlet var boutonExport: UIButton!
    @IBOutlet var stackViewPrincipal: UIStackView!
    @IBOutlet var segmentModeCongres: UISegmentedControl!

    @IBOutlet var contrainteLargeurBoutonEffacerLarge: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonExporterLarge: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonEffacerEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonExporterEtroit: NSLayoutConstraint!
    
    @IBOutlet var contrainteBasTableViewCamp: NSLayoutConstraint!
    @IBOutlet var contrainteBasTableViewCongres: NSLayoutConstraint!
    
    override func viewDidLoad() {
        boutonEffacerDonnees.setTitle("", for: .normal) // ⌫  "\u{0232B}"
        boutonExport.setTitle("", for: .normal)
        segmentModeCongres.isHidden = lEvenement.evenement == .camp
        segmentModeCongres.setTitle(NSLocalizedString("Organisateur", comment: ""), forSegmentAt: 0)
        segmentModeCongres.setTitle(NSLocalizedString("Participant", comment: ""), forSegmentAt: 1)
        var modeCongres = userDefaults.value(forKey: keyModeCongres) as? Int ?? -1
        if modeCongres >= 0 && modeCongres < segmentModeCongres.numberOfSegments {
            premierLancement = false
            segmentModeCongres.selectedSegmentIndex = modeCongres
            switchCollectifIndividuel(mode: modeCongres)
        } else if lEvenement.evenement == .congresCollectif || lEvenement.evenement == .congresIndividuel {
            premierLancement = true
            modeCongres = segmentModeCongres.selectedSegmentIndex
        }
        contrainteBasTableViewCamp.isActive = lEvenement.evenement == .camp
        if lEvenement.evenement != .camp {
            contrainteBasTableViewCongres = NSLayoutConstraint(item: tableViewEmissions!, attribute: .bottom, relatedBy: .equal, toItem: segmentModeCongres, attribute: .top, multiplier: 1.0, constant: -8.0)
            contrainteBasTableViewCongres.isActive = true
        }
        
        lEvenement.actualiseValeursMax()
        emissionsCalculees = lEvenement.calculeEmissions(typesEmissions: lEvenement.lesEmissions)
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
    

    @IBAction func modeCongresChange() {
        let modeCongres = segmentModeCongres.selectedSegmentIndex
        switchCollectifIndividuel(mode: modeCongres)
        tableViewEmissions.reloadData()
        userDefaults.set(modeCongres, forKey: keyModeCongres)
        emissionsCalculees = lEvenement.calculeEmissions(typesEmissions: lEvenement.lesEmissions)
        DispatchQueue.main.async {
            self.boutonEffacerDonnees.isHidden = emissionsCalculees == 0
            self.boutonExport.isHidden = emissionsCalculees == 0
        }
        actualiseAffichageEmissions()
        dessineCamembert(camembert: self.camembert, curseurActif: false, lesEmissions: lEvenement.lesEmissions, ligneActive: 0)
    }
    
    @objc func sectionTapped(sender: UITapGestureRecognizer) {
        print("tap")
        if sender.view != nil {
            let tapLocation = sender.location(in: tableViewEmissions)
                for i in 0..<tableViewEmissions.numberOfSections {
                    let sectionHeaderArea = tableViewEmissions.rectForHeader(inSection: i)
                    if sectionHeaderArea.contains(tapLocation) {
                        // do something with the section
                        print("tapped on section at index: \(i)")
                        if !lEvenement.sections[i].afficherLaSection || (lEvenement.sections[i].afficherLaSection && lEvenement.sections[i].emissionsSection == 0 && lEvenement.sections[i].optionnel) {
                            lEvenement.sections[i].afficherLaSection.toggle()
                            tableViewEmissions.reloadData()
                        }
                    }
                }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if premierLancement && lEvenement.evenement == .congresCollectif || lEvenement.evenement == .congresIndividuel {
            super.viewDidAppear(animated)
            let alerte = UIAlertController(title: NSLocalizedString("Bienvenue", comment: ""), message: NSLocalizedString("Évaluez l'impact climatique global d'un congrès, en tant qu'organisateur, ou bien votre impact individuel en tant que participant.\n\nVous pourrez modifier ce choix par la suite grâce au sélecteur situé sous le tableau principal", comment: ""), preferredStyle: .alert)
            alerte.addAction(UIAlertAction(title: NSLocalizedString("Organisateur", comment: ""), style: .default, handler: {_ in
                switchCollectifIndividuel(mode: 0)
                self.segmentModeCongres.selectedSegmentIndex = 0
                self.modeCongresChange()
            }))
            alerte.addAction(UIAlertAction(title: NSLocalizedString("Participant", comment: ""), style: .default, handler: {_ in
                switchCollectifIndividuel(mode: 1)
                self.segmentModeCongres.selectedSegmentIndex = 1
                self.modeCongresChange()
            }))
            DispatchQueue.main.async{
                self.present(alerte, animated: true)
            }
        }
        self.redessineResultats(size: self.view.frame.size, curseurActif: false)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lEvenement.sections.count
    }
    
    
    //// gestion des tableView
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lEvenement.lesEmissions.filter({$0.categorie == lEvenement.sections[section].nom}).count
    }
    
    func numeroDeLigne(indexPath: IndexPath) -> Int {
        var compteur: Int = 0
        let nomDeSection = lEvenement.sections[indexPath.section].nom
        while lEvenement.lesEmissions[compteur].categorie != nomDeSection {compteur = compteur + 1}
        return compteur + indexPath.row
    }
    
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        //        print("Cell for row at index path \(indexPath)")
        if indexPath.section < lEvenement.sections.count - 1 {  // les vraies données
            if lEvenement.sections[indexPath.section].afficherLaSection {
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
        cell.labelCopyright.text = lEvenement.texteCopyright
        let adresseWeb = lEvenement.texteAdresseWeb
        cell.boutonAdresseWeb.setTitle(adresseWeb, for: .normal)
        cell.boutonOuvrirWeb.setTitle("", for: .normal)
        let image = lEvenement.logo
        cell.imageLogo.image = image
        return cell
    }
    
    func creeCelluleVide (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewEmissions.dequeueReusableCell(withIdentifier: cellReuseIdentifierVide, for: indexPath) as! CelluleVide
        cell.selectionStyle = .none
        cell.backgroundColor = lEvenement.couleurs5[indexPath.section].withAlphaComponent(0.3)
        cell.delegate = self
        return cell
    }
    
    func creeCelluleNormale (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ligne = numeroDeLigne(indexPath: indexPath)
        let emission = lEvenement.lesEmissions[ligne]
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
        let mettreTitreCelluleEnRouge = indexPath.section == 0 && lEvenement.lesEmissions[ligne].facteurEmission == 0.0 && lEvenement.lesEmissions[ligne].valeur == 0
        if #available(iOS 13.0, *) {
            cell.labelNom.textColor = mettreTitreCelluleEnRouge ? .red : .label
        } else {
            // Fallback on earlier versions
            cell.labelNom.textColor = mettreTitreCelluleEnRouge ? .red : .black
        }

        cell.labelValeur.isHidden = true // l'emplacement de la loupe qui indique le zoom
        cell.actualiseEmissionIndividuelle(typeEmission: emission)
        cell.labelEmissionIndividuelle.font = .monospacedDigitSystemFont(ofSize: cell.labelEmissionIndividuelle.font.pointSize, weight: .regular)
        cell.boutonInfo.isHidden = emission.conseil.isEmpty
        cell.backgroundColor = lEvenement.couleurs5[indexPath.section].withAlphaComponent(0.3)
        cell.boutonInfo.setTitle("\u{2007}", for: .normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var titreSection = lEvenement.sections[section].nom
        if lEvenement.sections[section].emissionsSection > 0 {
            let pourcentage = lEvenement.sections[section].emissionsSection / emissionsCalculees * 100.0
            let textePourcentage = pourcentage < 0.5 ? NSLocalizedString(" (< 1%)", comment: "") : String(format: NSLocalizedString(" (%.0f%%)", comment: ""), pourcentage)

            titreSection = titreSection + textePourcentage
        }
        let margeVerticale = CGFloat(12.0)
        let margeHorizontale = CGFloat(20.0)
        let hauteurLabel = CGFloat(24.0)
        let headerView = UIView() //frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: hauteurLabel + 2 * margeVerticale))
        headerView.backgroundColor = lEvenement.couleurs5[section]
        let headerLabel = UILabel(frame: CGRect(x: margeHorizontale, y: margeVerticale, width: tableView.bounds.size.width - 2 * margeHorizontale, height: hauteurLabel))
        headerLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).withSize(21) //  .boldSystemFont(ofSize: 24) // UIFont(name: "Verdana", size: 20)
        var blanc: CGFloat = 0
        var alpha: CGFloat = 0
        lEvenement.couleurs5[section].getWhite(&blanc, alpha: &alpha)
        headerLabel.textColor = blanc > 0.5 ? .black : .white
        headerLabel.text = titreSection
        headerLabel.numberOfLines = 1
        headerLabel.adjustsFontSizeToFitWidth = true
        headerView.addSubview(headerLabel)
        
        return headerView
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if lEvenement.sections[section].nom == "" {
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
            let message = lEvenement.lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].conseil //  cell.labelConseil.text
            let nomsRessources = lEvenement.lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].nomsRessources
            let liensRessources = lEvenement.lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].liensRessources
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
        for i in 0...lEvenement.lesEmissions.count - 1 {
            lEvenement.lesEmissions[i].valeur = 0.0 // lEvenement.lesEmissions[i].facteurEmission > 0 ? //0.0 : 1.0  // pour la durée et l'effectif, on met 1 par défaut, pas zéro
        }
        lEvenement.actualiseValeursMax()
        emissionsCalculees = lEvenement.calculeEmissions(typesEmissions: lEvenement.lesEmissions)
        boutonExport.isHidden = emissionsCalculees == 0
        boutonEffacerDonnees.isHidden = emissionsCalculees == 0
        let lesValeurs = lEvenement.lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: lEvenement.keyData)
        
        DispatchQueue.main.async {
            self.tableViewEmissions.reloadData()
            self.tableViewEmissions.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.actualiseAffichageEmissions()
            self.dessineCamembert(camembert: self.camembert, curseurActif: false, lesEmissions: lEvenement.lesEmissions, ligneActive: ligneEnCours)
        }
    }
    
    func debutMouvementGlissiere(cell: CelluleEmission){
        guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
            print("erreur index Path - debut mouvement glissière")
            return
        }
        ligneEnCours = numeroDeLigne(indexPath: indexPath)
        minValueNonZoomee = cell.glissiere.minimumValue
        maxValueNonZoomee = cell.glissiere.maximumValue
        valeurPrecedente = cell.glissiere.value
        glissiereModeZoom = false
        lancerTimerZoom(cell: cell, ligne: ligneEnCours)
    }
    
    func lancerTimerZoom(cell: CelluleEmission, ligne: Int) {
        if !self.glissiereModeZoom && ((cell.glissiere.maximumValue - cell.glissiere.minimumValue) / facteurZoomGlissiere >= 3 || lEvenement.lesEmissions[ligne].echelleLog) {
            let valeur = cell.glissiere.value
            let compteurAuDebutDuTimer = self.compteurMouvementsGlissiere
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if compteurAuDebutDuTimer == self.compteurMouvementsGlissiere && abs(valeur - cell.glissiere.value) < 0.02 * (cell.glissiere.maximumValue - cell.glissiere.minimumValue) && !self.glissiereModeZoom {
                    //                    print("zoom", compteurAuDebutDuTimer, self.compteurMouvementsGlissiere, ligne)
                    self.activerModeZoomGlissiere(ligne: ligne, cellule: cell, echelleLog: lEvenement.lesEmissions[ligne].echelleLog)
                }
            }
        }
    }
    
    func glissiereBougee(cell: CelluleEmission) {
        guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
            print("erreur index Path - glissière bougée")
            return
        }
        let ligne = numeroDeLigne(indexPath: indexPath)
        let emission = lEvenement.lesEmissions[ligne]
        lancerTimerZoom(cell: cell, ligne: ligne)
        self.valeurPrecedente = cell.glissiere.value
        if emission.echelleLog {
            if cell.glissiere.value == self.minValueNonZoomee { //  cellule!.glissiere.minimumValue {
                lEvenement.lesEmissions[ligne].valeur = 0.0
            } else {
                lEvenement.lesEmissions[ligne].valeur = arrondi(exp(Double(cell.glissiere.value)))
            }
        } else {
            lEvenement.lesEmissions[ligne].valeur = Double(cell.glissiere.value)
            if emission.valeurEntiere {
                lEvenement.lesEmissions[ligne].valeur = round(lEvenement.lesEmissions[ligne].valeur)
            }
        }
        lEvenement.ajusteQuantitesLiees(ligne: ligne)
        emissionsCalculees = lEvenement.calculeEmissions(typesEmissions: lEvenement.lesEmissions)
        cell.labelNom.text = texteNomValeurUnite(emission: lEvenement.lesEmissions[ligne]) //, afficherPictos: afficherPictos)
        let mettreTitreCelluleEnRouge = indexPath.section == 0 && lEvenement.lesEmissions[ligne].facteurEmission == 0.0 && lEvenement.lesEmissions[ligne].valeur == 0
        if #available(iOS 13.0, *) {
            cell.labelNom.textColor = mettreTitreCelluleEnRouge ? .red : .label
        } else {
            // Fallback on earlier versions
            cell.labelNom.textColor = mettreTitreCelluleEnRouge ? .red : .black
        }

        DispatchQueue.main.async{
            self.boutonExport.isHidden = emissionsCalculees == 0
            self.boutonEffacerDonnees.isHidden = emissionsCalculees == 0
            cell.actualiseEmissionIndividuelle(typeEmission: lEvenement.lesEmissions[ligne])  // Bizarre, devrait être déjà inclus dans le reloadRows
            self.actualiseAffichageEmissions()
            self.dessineCamembert(camembert: self.camembert, curseurActif: true, lesEmissions: lEvenement.lesEmissions, ligneActive: ligneEnCours)
        }  // DispatchQueue.main.async
    }
    
    
    func finMouvementGlissiere(cell: CelluleEmission) {
        glissiereBougee(cell: cell)
        ligneEnCours = -1
        self.compteurMouvementsGlissiere = self.compteurMouvementsGlissiere + 1
        let lesValeurs = lEvenement.lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: lEvenement.keyData)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableViewEmissions.reloadData()
            self.dessineCamembert(camembert: self.camembert, curseurActif: false, lesEmissions: lEvenement.lesEmissions, ligneActive: ligneEnCours)
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
    
    override func choisitContraintes(size: CGSize, orientationGlobale: Orientation) -> Bool {
        let nouvelleOrientation: Orientation = size.width <= size.height ? .portrait : .paysage
        var change = false
        if nouvelleOrientation == .portrait && self.stackViewPrincipal.axis != .vertical {
            self.stackViewPrincipal.axis = .vertical
            change = true
        } else if nouvelleOrientation == .paysage && self.stackViewPrincipal.axis != .horizontal {
            self.stackViewPrincipal.axis = .horizontal
            change = true
        }
        let change2 = super.choisitContraintes(size: self.vueResultats.frame.size, orientationGlobale: nouvelleOrientation)
        return change || change2
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
    
    func ouvrirWebCredits() {
        let adresse = lEvenement.texteLienWeb
        ouvrirWeb(adresse: adresse)
    }
    
    
    func redessineResultats(size: CGSize, curseurActif: Bool) {
        DispatchQueue.main.async {
            self.actualiseAffichageEmissions()
            let delai = self.choisitContraintes(size: size, orientationGlobale: .inconnu) ? 0.05 : 0.00
            DispatchQueue.main.asyncAfter(deadline: .now() + delai) {
                self.dessineCamembert(camembert: self.camembert, curseurActif: curseurActif, lesEmissions: lEvenement.lesEmissions, ligneActive: ligneEnCours)
            }
        }
        if ligneEnCours < 0 { // pour ne pas actualiser le tableView pendant qu'on manipule un curseur
            tableViewEmissions.reloadData()
        }
    }
        
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
        let leTexte = texteListeEmissions(lesEmissions: lEvenement.lesEmissions, pourTexteBrut: true).string
        let sujet = lEvenement.texteImpactClimat
        var items: [Any] = [EmailSubjectActivityItemSource(subject: sujet, emailBody: leTexte)]
        if let urlPDFAExporter = generePDF() {
            print("pdf ok")
            items.append(urlPDFAExporter)
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil) // "" : le corps du message intégré automatiquement
            if let popover = activityViewController.popoverPresentationController {
                popover.barButtonItem  = self.navigationItem.rightBarButtonItem
                popover.permittedArrowDirections = .any
                popover.sourceView = sender // sender;
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
            let textePourPdf1 = texteListeEmissions(lesEmissions: lEvenement.lesEmissions, pourTexteBrut: false)
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
    
}
