//
//  ViewController.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 04/09/2022.
//

// *** Priorite 1 ***
// AFFICHAGE / mise en page
// - Dessin du camembert : erreur de contexte + intégrer ce qui peut l'être à la classe Graphique (ou la supprimer ?)
// - compléter les explications du graphique et du texte associé
// - le camembert se cale en bas quand la vue est verticale très allongée

// *** Priorité 2 ***
// INTERFACE
// - Localisation, y compris les noms de types d'émission
// - éviter les superposition de textes dans le camembert

// *** A décider ***
// sliders : largeur fixe ?
// - Dégradé de couleur interne à chaque section ??

import UIKit
//import AVFoundation

//let notificationEmetteursChanges = "notificationEmetteursChanges"
let notificationBackground = "notificationBackground"
var emissionsCalculees: Double = .nan
var emissionsSoutenables: Double = .nan
var lesSections: [String] = []
//var effectif: Double = .nan
let userDefaults = UserDefaults.standard
let largeurMiniTableViewEcranLarge:CGFloat = 400
var lesEmissions: [TypeEmission] = []
let emissionsSoutenablesAnnuelles: Double = 2500.0 // t eq. C02 / an / personne

class ViewController: ViewControllerAvecCamembert, UITableViewDelegate, UITableViewDataSource, CelluleEmissionDelegate, UIPopoverControllerDelegate {
    // UIPopoverPresentationControllerDelegate, ConseilDelegate
    
    let keyValeursUtilisateurs = "keyValeursUtilisateurs"
    //    var camp = CaracteristiquesCamp()
    
    let cellReuseIdentifier = "CelluleEmission"
    @IBOutlet var tableViewEmissions: UITableView!
    @IBOutlet var vueResultats: UIView!
    @IBOutlet var boutonOuvrirGrandCamembert: UIButton!
        
    @IBOutlet var contrainteTableViewHautPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewHautPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewDroitePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewDroitePaysage: NSLayoutConstraint!
    
    @IBOutlet var contrainteVueResultatsGauchePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteVueResultatsBasPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteVueResultatGauchePaysage: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (lesEmissions, lesSections) = lireFichier(nom: "Data")
        let lesValeurs = userDefaults.value(forKey: keyValeursUtilisateurs) as? [Double] ?? []
        if !lesValeurs.isEmpty && lesValeurs.count == lesEmissions.count {
            for i in 0...lesValeurs.count - 1 {
                lesEmissions[i].valeur = lesValeurs[i]
            }
        }
        tableViewEmissions.delegate = self
        tableViewEmissions.dataSource = self
        actualiseValeursMaxRepas(valeurMax: lesEmissions[SorteEmission.duree.rawValue].valeur)
        actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
//        if #available(iOS 13.0, *) {
//            affichageEmissions.backgroundColor = .systemBackground.withAlphaComponent(0.2)
//        } else {
//            affichageEmissions.backgroundColor = .white.withAlphaComponent(0.2)
//        }

        boutonOuvrirGrandCamembert.setTitle("", for: .normal)
        emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)
        if #available(iOS 15.0, *) {
          tableViewEmissions.sectionHeaderTopPadding = 0
        }
        DispatchQueue.main.async {
            self.actualiseAffichageEmissions()
            self.dessineCamembert(camembert: self.camembert)

            self.tableViewEmissions.reloadData()
        }
    }  // viewDidLoad
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        choisitContraintes(size: self.view.frame.size)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lesSections.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return lesSections[section]
//    }
    
    
    //// gestion des tableView
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lesEmissions.filter({$0.categorie == lesSections[section]}).count
    }
    
    func numeroDeLigne(indexPath: IndexPath) -> Int {
        var compteur: Int = 0
        let nomDeSection = lesSections[indexPath.section]
        while lesEmissions[compteur].categorie != nomDeSection {compteur = compteur + 1}
        return compteur + indexPath.row
    }
    
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let emission = lesEmissions[numeroDeLigne(indexPath: indexPath)] //  lesEmissions.filter({$0.categorie == lesSections[indexPath.section]})[indexPath.row]
        let cell = tableViewEmissions.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CelluleEmission
        // set the text from the data model
            cell.delegate = self
            cell.choisitContraintes()
            cell.selectionStyle = .none
            cell.labelNom.text = emission.nom
            if emission.echelleLog {
                cell.glissiere.minimumValue = Float(2.3)
                cell.glissiere.maximumValue = log(Float(emission.valeurMax))
                cell.glissiere.value = log(Float(emission.valeur))
            } else {
                cell.glissiere.minimumValue = Float(0.0)
                cell.glissiere.maximumValue = Float(emission.valeurMax)
                cell.glissiere.value = Float(emission.valeur)
            }
            cell.labelValeur.text = String(format: self.formatAffichageValeur(valeurMax: emission.valeurMax) + emission.unite, emission.valeur).replacingOccurrences(of: " ", with: "\u{2007}") // on remplace les espaces par des blancs par des espaces de largeur fixe insécables
            cell.labelValeur.font = UIFont.monospacedDigitSystemFont(ofSize: cell.labelValeur.font.pointSize, weight: .regular)
        cell.actualiseEmissionIndividuelle(typeEmission: emission)
//            let (texte, couleur) = texteEmissionsLigne(typeEmission: emission)
//            cell.labelEmissionIndividuelle.text = texte
//            cell.labelEmissionIndividuelle.textColor = couleur
            cell.boutonInfo.isEnabled = !emission.conseil.isEmpty
        cell.backgroundColor = couleursEEUdF6[indexPath.section].withAlphaComponent(0.4) // UIColor(morgenStemningNumber: indexPath.section, MorgenStemningScaleSize: lesSections.count).withAlphaComponent(0.5)
            cell.boutonInfo.setTitle("", for: .normal)
        return cell
    }
    
    func formatAffichageValeur(valeurMax: Double) -> String {
        let nombreChiffresMax = valeurMax > 0 ? Int(ceil(log(valeurMax) / log(10.0) + 0.01)) : 1
        switch nombreChiffresMax {
        case 2: return "%2.0f "
        case 3: return "%3.0f "
        case 4: return "%4.0f "
        default: return "%.0f "
        }
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var titreSection = lesSections[section]
        let lesEmissionsDeLaSection = lesEmissions.filter({$0.categorie == titreSection}).map({$0.emission})
        let emissionsTotalesSection = lesEmissionsDeLaSection.reduce(0.0, +)
        if emissionsTotalesSection > 0 {
            titreSection = titreSection + String(format: " (%.0f %%)", emissionsTotalesSection / emissionsCalculees * 100.0)
        }
        let margeVerticale = CGFloat(12.0)
        let margeHorizontale = CGFloat(20.0)
        let hauteurLabel = CGFloat(24.0)
        let headerView = UIView() //frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: hauteurLabel + 2 * margeVerticale))
//        headerView.frame.size.height = hauteurLabel + 2 * margeVerticale
        headerView.backgroundColor = couleursEEUdF6[section] //UIColor(morgenStemningNumber: section, MorgenStemningScaleSize: lesSections.count) //.withAlphaComponent(0.7)
        
        let headerLabel = UILabel(frame: CGRect(x: margeHorizontale, y: margeVerticale, width: tableView.bounds.size.width - 2 * margeHorizontale, height: hauteurLabel))
        headerLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).withSize(21) //  .boldSystemFont(ofSize: 24) // UIFont(name: "Verdana", size: 20)
        //            headerLabel.textColor = UIColor.white
        headerLabel.text = titreSection // self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.numberOfLines = 1
//        headerLabel.backgroundColor = .blue
        headerLabel.adjustsFontSizeToFitWidth = true
//        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
//        headerView.sizeToFit()
        return headerView
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight: CGFloat = 48
        if #available(iOS 11.0, *) {
            tableView.estimatedSectionHeaderHeight = headerHeight
            return UITableView.automaticDimension
        } else {
            return headerHeight
        }
    }

    
    func afficheConseil(cell: CelluleEmission){
        var message = ""
        if let indexPathDeLaCellule = tableViewEmissions.indexPath(for: cell) {
                    message = lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].conseil //  cell.labelConseil.text
                }
        let alerte = UIAlertController(title: "Un conseil", message: message, preferredStyle: .alert)
        alerte.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "bouton OK"), style: .default, handler: nil))
        self.present(alerte, animated: true)
    }
    
    
    func glissiereBougee(cell: CelluleEmission) {

        guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
            print("erreur index Path")
            return
        }
        let ligne = numeroDeLigne(indexPath: indexPath)
        print("ligne \(ligne)")

        let emission = lesEmissions[ligne]
        if emission.valeurEntiere {
            cell.glissiere.value = round(cell.glissiere.value)
        }
        if emission.echelleLog {
            if cell.glissiere.value == cell.glissiere.minimumValue {
                lesEmissions[ligne].valeur = 0.0
            } else {
                lesEmissions[ligne].valeur = arrondi(exp(Double(cell.glissiere.value)))
            }
        } else {
            lesEmissions[ligne].valeur = Double(cell.glissiere.value)
        }
        cell.labelValeur.text = String(format: formatAffichageValeur(valeurMax: emission.valeurMax) + emission.unite, lesEmissions[ligne].valeur).replacingOccurrences(of: " ", with: "\u{2007}")
        switch ligne {
        case SorteEmission.duree.rawValue:
            actualiseValeursMaxRepas(valeurMax: lesEmissions[SorteEmission.duree.rawValue].valeur)
            lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur - lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur - lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur
            if lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur < 0 {
                lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur = 0
                lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur - lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur
                if lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur < 0 {
                    lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur = 0
                    lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur
                }
            }
        case SorteEmission.repasViandeRouge.rawValue:
            lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur - lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur - lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur
            if lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur < 0 {
                lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur = 0
                lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur - lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur
            }
        case SorteEmission.repasViandeBlanche.rawValue:
            lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur - lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur - lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur
            if lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur < 0 {
                lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur = 0
                lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur - lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur
            }
        case SorteEmission.repasVegetarien.rawValue:
            lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur - lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur - lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur
            if lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur < 0 {
                lesEmissions[SorteEmission.repasViandeBlanche.rawValue].valeur = 0
                lesEmissions[SorteEmission.repasViandeRouge.rawValue].valeur = 2 * lesEmissions[SorteEmission.duree.rawValue].valeur - lesEmissions[SorteEmission.repasVegetarien.rawValue].valeur
            }
        case SorteEmission.effectif.rawValue:
            actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
        default:
            print("rien")
        }
        emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)

        DispatchQueue.main.async{
            cell.actualiseEmissionIndividuelle(typeEmission: lesEmissions[ligne])
//            let (texte, couleur) = texteEmissionsLigne(typeEmission: lesEmissions[ligne])
//            cell.labelEmissionIndividuelle.text = texte
//            cell.labelEmissionIndividuelle.textColor = couleur
        }
    }
    
    func finMouvementGlissiere(cell: CelluleEmission) {
        let lesValeurs = lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: keyValeursUtilisateurs)
        DispatchQueue.main.async{
            self.dessineCamembert(camembert: self.camembert)
            self.actualiseAffichageEmissions()
           self.tableViewEmissions.reloadData()
        }
    }
    

    func actualiseValeursMaxEffectif(valeurMax: Double) {
        for i in 0...lesEmissions.count-1 {
            if lesEmissions[i].valeurMaxSelonEffectif > 0 {
                lesEmissions[i].valeurMax = valeurMax * lesEmissions[i].valeurMaxSelonEffectif
                lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
            }
        }
    }
    
    func actualiseValeursMaxRepas(valeurMax: Double) {
        for i in 0...lesEmissions.count-1 {
            if lesEmissions[i].valeurMaxNbRepas > 0 {
                lesEmissions[i].valeurMax = valeurMax * lesEmissions[i].valeurMaxNbRepas
                lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
            }
        }
    }
        
    override func choisitContraintes(size: CGSize){
        super.choisitContraintes(size: self.vueResultats.frame.size)
        let estModePortrait = size.width <= size.height
            self.contrainteTableViewHautPortrait.isActive = estModePortrait
            self.contrainteTableViewDroitePortrait.isActive = estModePortrait
            self.contrainteVueResultatsGauchePortrait.isActive = estModePortrait

            self.contrainteTableViewHautPaysage.isActive = !estModePortrait
            self.contrainteTableViewDroitePaysage.isActive = !estModePortrait
            self.contrainteVueResultatsBasPaysage.isActive = !estModePortrait
            self.contrainteVueResultatGauchePaysage.isActive = !estModePortrait
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = self.view.frame.size
        choisitContraintes(size: size)
        DispatchQueue.main.async {
            self.dessineCamembert(camembert: self.camembert)
        }
        tableViewEmissions.reloadData()
    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.choisitContraintes(size: self.view.frame.size)
            self.dessineCamembert(camembert: self.camembert)
        }
        tableViewEmissions.reloadData()
    }
    

    
}

