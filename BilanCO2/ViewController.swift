//
//  ViewController.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 04/09/2022.
//

// *** Priorite 1 ***
// AFFICHAGE / mise en page
// Réduire la taille minimum de la fenêtre sur mac
// Mac Layout portrait / Paysage : Problème de basculement intempestif
// - Dégradé de couleur interne à chaque section
// - icone : alpha channel
// - splitview écran étroit, le premier affichage du tableview est faux
// *** Priorité 2 ***
// INTERFACE
// - Conseil : meilleure option que l'alerte ?
// - Localisation, y compris les noms de types d'émission
// - éviter les superposition de textes dans le camembert

// *** A décider ***
// sliders : largeur fixe ?

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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CelluleEmissionDelegate, UIPopoverControllerDelegate {
    // UIPopoverPresentationControllerDelegate, ConseilDelegate
    
    var lesEmissions: [TypeEmission] = []
    let keyValeursUtilisateurs = "keyValeursUtilisateurs"
    //    var camp = CaracteristiquesCamp()
    
    let cellReuseIdentifier = "CelluleEmission"
    @IBOutlet var affichageEmissions: UILabel!
    @IBOutlet var tableViewEmissions: UITableView!
    @IBOutlet var vueResultats: UIView!
    @IBOutlet var camembert: UIImageView!
    @IBOutlet var boutonAideGraphique: UIButton!
    
    @IBOutlet var contrainteAffichageEmissionsDroitePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsDroitePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsBasPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteAffichageEmissionsBasPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertGauchePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertGauchePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteCamembertHautPortrait: NSLayoutConstraint!
    
    @IBOutlet var contrainteTableViewHautPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewHautPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewDroitePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewDroitePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteVueResultatsGauchePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteVueResultatsBasPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteVueResultatGauchePaysage: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        (lesEmissions, lesSections) = lireFichier(nom: "Data")
        let lesValeurs = userDefaults.value(forKey: keyValeursUtilisateurs) as? [Double] ?? []
        if !lesValeurs.isEmpty && lesValeurs.count == lesEmissions.count {
            for i in 0...lesValeurs.count - 1 {
                lesEmissions[i].valeur = lesValeurs[i]
            }
        }
        tableViewEmissions.delegate = self
        tableViewEmissions.dataSource = self
        actualiseAffichageEmissions()
//        if #available(iOS 13.0, macOS 11.0, *) {
        boutonAideGraphique.setTitle("", for: .normal)
//    } else {boutonAideGraphique.setTitle("ℹ️", for: .normal)}
        DispatchQueue.main.async {
            self.dessineCamembert()
            self.tableViewEmissions.reloadData()
        }
        //        NotificationCenter.default.addObserver(self, selector: #selector(choisitContraintesDepuisNotification), name: Notification.Name(notificationBackground), object: nil)
    }  // viewDidLoad
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        choisitContraintes(size: self.view.frame.size)
        
    }
    
    @objc func actualiseAffichageEmissions() {
        //        print("affichage")
        DispatchQueue.main.async{
            let (texte, couleur) = texteEmissions(typesEmissions: self.lesEmissions)
            self.affichageEmissions.text = texte
            self.affichageEmissions.textColor = couleur
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return lesSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return lesSections[section]
    }
    
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        <#code#>
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
        actualiseValeursMaxRepas(valeurMax: lesEmissions[SorteEmission.duree.rawValue].valeur)
        actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
        let cell = tableViewEmissions.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CelluleEmission
        // set the text from the data model
//        DispatchQueue.main.async {
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
            let (texte, couleur) = texteEmissionsLigne(typeEmission: emission)
            cell.labelEmissionIndividuelle.text = texte
            cell.labelEmissionIndividuelle.textColor = couleur
            cell.boutonInfo.isEnabled = !emission.conseil.isEmpty
            cell.backgroundColor = UIColor(morgenStemningNumber: indexPath.section, MorgenStemningScaleSize: lesSections.count).withAlphaComponent(0.5)
//            if #available(iOS 13.0, macOS 11.0, *) {
            cell.boutonInfo.setTitle("", for: .normal)
//        } else {cell.boutonInfo.setTitle("ℹ️", for: .normal)}
//        }
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
    
    //    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    //    {
    //        let header = view as! UITableViewHeaderFooterView
    //        header.textLabel?.font = .systemFont(ofSize: 21)  //UIFont(name: "Futura", size: 38)!
    //        header.textLabel?.textColor = .red // UIColor.lightGrayColor()
    //        header.backgroundColor = UIColor(morgenStemningNumber: section, MorgenStemningScaleSize: lesSections.count).withAlphaComponent(0.7)
    //    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var titreSection = lesSections[section]
        let lesEmissionsDeLaSection = lesEmissions.filter({$0.categorie == titreSection}).map({$0.emission})
        let emissionsTotalesSection = lesEmissionsDeLaSection.reduce(0.0, +)
        if emissionsTotalesSection > 0 {
            titreSection = titreSection + String(format: " (%.0f %%)", emissionsTotalesSection / emissionsCalculees * 100.0)
        }
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(morgenStemningNumber: section, MorgenStemningScaleSize: lesSections.count).withAlphaComponent(0.7)
        
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 12, width: tableView.bounds.size.width - 40, height: 24))
        headerLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline).withSize(21) //  .boldSystemFont(ofSize: 24) // UIFont(name: "Verdana", size: 20)
        //            headerLabel.textColor = UIColor.white
        headerLabel.text = titreSection // self.tableView(self.tableView, titleForHeaderInSection: section)
        headerLabel.numberOfLines = 2
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        headerView.sizeToFit()
        return headerView
    }
    
    
    func finMouvementGlissiere(cell: CelluleEmission) {
        let lesValeurs = lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: keyValeursUtilisateurs)
        DispatchQueue.main.async{
            self.tableViewEmissions.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight: CGFloat = 85
        if #available(iOS 11.0, *) {
            tableView.estimatedSectionHeaderHeight = headerHeight
            return UITableView.automaticDimension
        } else {
            return headerHeight
        }
    }
    
    
    
    @IBAction func afficheExplicationsFigure() {
        let message = "Ce graphique représente la répartition des émisssions du camp. Le cercle vert permet de les comparer avec les émissions soutenables, soit l'équivalent de 2,5 tonnes équivalent CO2 par personne et par an, rapportées à la durée du camp."
        let alerte = UIAlertController(title: "Pour en savoir plus", message: message, preferredStyle: .alert)
        alerte.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "bouton OK"), style: .default, handler: nil))
        self.present(alerte, animated: true)
//
//        let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "Conseil") as? Conseil
//        let taille = camembert.frame.size
//        let taillePreferee = min(300, taille.width * 0.75, taille.height * 0.75)
//        popoverViewController?.preferredContentSize = CGSize(width: taillePreferee, height: taillePreferee)
//        let frame = popoverViewController?.view.frame ?? CGRect(x: 20, y: 20, width: 300, height: 300)
//        let preferredSize = popoverViewController?.preferredContentSize ?? CGSize(width: 300, height: 300)
//        let label = UILabel(frame: CGRect(x: frame.minX + 50, y: frame.minY + 50, width: preferredSize.width, height: preferredSize.height - 50))
//        label.text = "Ce graphique représente la répartition des émisssions du camp. Le cercle vert permet de les comparer avec les émissions soutenables, soit l'équivalent de 2,5 tonnes équivalent CO2 par personne et par an, rapportées à la durée du camp."
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//        label.preferredMaxLayoutWidth = frame.width - 100
//        label.sizeToFit()
//        popoverViewController?.view.addSubview(label)
//        let bouton = UIButton(type: .system)
//        bouton.setTitle("OK", for: .normal)
//        bouton.frame = CGRect(x: label.frame.minX, y: label.frame.maxY + 16, width: 30, height: 30)
////        bouton.frame = CGRect(x: 100, y: 100, width: 30, height: 30)
//        bouton.addTarget(self, action: #selector(fermerPopover), for: .touchUpInside)
//        popoverViewController?.view.addSubview(bouton)
////        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(fermerPopover))
////        tapRecognizer.delegate = self
////        popoverViewController?.tabBarObservedScrollView?.addGestureRecognizer(tapRecognizer)
//        let popoverPresentationViewController = popoverViewController?.popoverPresentationController
//
//        popoverPresentationViewController?.permittedArrowDirections = UIPopoverArrowDirection.any
//        //        popoverPresentationViewController?.delegate = self
//        popoverPresentationViewController?.sourceView = boutonAideGraphique
//        popoverPresentationViewController?.sourceRect = boutonAideGraphique.frame // CGRectMake(RoutineLabel.frame.width / 2, RoutineLabel.frame.height,0,0)
//        DispatchQueue.main.async{
//            self.present(popoverViewController!, animated: true, completion: nil)
//        }
    }
    
//    @objc func fermerPopover() {
//        if let popover = self.presentedViewController {
//            popover.dismiss(animated: false, completion: nil)
//        }
//    }
    
    func afficheConseil(cell: CelluleEmission){
        var message = ""
        if let indexPathDeLaCellule = tableViewEmissions.indexPath(for: cell) {
                    message = lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].conseil //  cell.labelConseil.text
                }
        let alerte = UIAlertController(title: "Un conseil", message: message, preferredStyle: .alert)
        alerte.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "bouton OK"), style: .default, handler: nil))
        self.present(alerte, animated: true)

//        let popoverViewController = self.storyboard?.instantiateViewController(withIdentifier: "Conseil") as? Conseil
//        let taille = self.view.frame.size
//        let taillePreferee = min(300, taille.width * 0.75, taille.height * 0.75)
//        popoverViewController?.preferredContentSize = CGSize(width: taillePreferee, height: taillePreferee)
//        let frame = popoverViewController?.view.frame ?? CGRect(x: 20, y: 20, width: 300, height: 300)
//        let preferredSize = popoverViewController?.preferredContentSize ?? CGSize(width: 300, height: 300)
//        let label = UILabel(frame: CGRect(x: frame.minX + 50, y: frame.minY + 50, width: preferredSize.width, height: preferredSize.height - 50))
//        if let indexPathDeLaCellule = tableViewEmissions.indexPath(for: cell) {
//            label.text = lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].conseil //  cell.labelConseil.text
//        } else {
//            label.text = ""
//        }
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//        label.preferredMaxLayoutWidth = frame.width - 100
//        label.sizeToFit()
//        popoverViewController?.view.addSubview(label)
//        let bouton = UIButton(type: .system)
//        bouton.setTitle("OK", for: .normal)
//        bouton.frame = CGRect(x: label.frame.maxX + 16, y: label.frame.minY, width: 30, height: 30)
////        bouton.frame = CGRect(x: 100, y: 100, width: 30, height: 30)
//        bouton.addTarget(self, action: #selector(fermerPopover), for: .touchUpInside)
//        popoverViewController?.view.addSubview(bouton)
//
//        let popoverPresentationViewController = popoverViewController?.popoverPresentationController
//        popoverPresentationViewController?.permittedArrowDirections = UIPopoverArrowDirection.any
//        //        popoverPresentationViewController?.delegate = self
//        popoverPresentationViewController?.sourceView = cell.boutonInfo
//        popoverPresentationViewController?.sourceRect = cell.boutonInfo.frame // CGRectMake(RoutineLabel.frame.width / 2, RoutineLabel.frame.height,0,0)
//        DispatchQueue.main.async{
//            self.present(popoverViewController!, animated: true, completion: nil)
//        }
        //        cell.labelConseil.isHidden.toggle()
    }
    
    //    func ecritMessage(view: Conseil, texte: String) {
    ////        view.labelConseilPopover.text = texte
    //    }
    
    func glissiereBougee(cell: CelluleEmission) {
        guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
            print("erreur index Path")
            return
        }
        let ligne = numeroDeLigne(indexPath: indexPath)
        if lesEmissions[ligne].valeurEntiere {
            cell.glissiere.value = round(cell.glissiere.value)
        }
        if lesEmissions[ligne].echelleLog {
            if cell.glissiere.value == cell.glissiere.minimumValue {
                lesEmissions[ligne].valeur = 0.0
            } else {
                lesEmissions[ligne].valeur = exp(Double(cell.glissiere.value))
            }
            //            cell.labelValeur.text = String(format: "%4.0f " + lesEmissions[ligne].unite, lesEmissions[ligne].valeur).replacingOccurrences(of: " ", with: "\u{2007}")
        } else {
            lesEmissions[ligne].valeur = Double(cell.glissiere.value)
        }
        cell.labelValeur.text = String(format: formatAffichageValeur(valeurMax: lesEmissions[ligne].valeurMax) + lesEmissions[ligne].unite, lesEmissions[ligne].valeur).replacingOccurrences(of: " ", with: "\u{2007}")
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
        if ligne == SorteEmission.duree.rawValue || ligne == SorteEmission.repasViandeRouge.rawValue || ligne == SorteEmission.repasViandeBlanche.rawValue {
            
        }
        
        DispatchQueue.main.async{
            self.actualiseAffichageEmissions()
            let (texte, couleur) = texteEmissionsLigne(typeEmission: self.lesEmissions[ligne])
            cell.labelEmissionIndividuelle.text = texte
            cell.labelEmissionIndividuelle.textColor = couleur
            self.dessineCamembert()
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
    
//    @objc func choisitContraintesDepuisNotification() {
//        choisitContraintes(size: self.view.frame.size)
//    }
    
    func choisitContraintes(size: CGSize){
        let estModePortrait = size.width <= size.height
        print("choisitContraintes width height portrait", size.width, size.height, estModePortrait)
//        DispatchQueue.main.async {
            self.contrainteAffichageEmissionsDroitePortrait.isActive = estModePortrait
            self.contrainteAffichageEmissionsBasPortrait.isActive = estModePortrait
            self.contrainteCamembertHautPortrait.isActive = estModePortrait
            self.contrainteCamembertGauchePortrait.isActive = estModePortrait
            
            self.contrainteTableViewHautPortrait.isActive = estModePortrait
            self.contrainteTableViewDroitePortrait.isActive = estModePortrait
            self.contrainteVueResultatsGauchePortrait.isActive = estModePortrait
            
            self.contrainteAffichageEmissionsDroitePaysage.isActive = !estModePortrait
            self.contrainteAffichageEmissionsBasPaysage.isActive = !estModePortrait
            self.contrainteCamembertGauchePaysage.isActive = !estModePortrait
            
            self.contrainteTableViewHautPaysage.isActive = !estModePortrait
            self.contrainteTableViewDroitePaysage.isActive = !estModePortrait
            self.contrainteVueResultatsBasPaysage.isActive = !estModePortrait
            self.contrainteVueResultatGauchePaysage.isActive = !estModePortrait
//        }
    }

//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        let size = self.view.frame.size
//        choisitContraintes(size: size)
//        DispatchQueue.main.async {
//            self.dessineCamembert()
//        }
//        tableViewEmissions.reloadData()
//    }

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.choisitContraintes(size: size)
            self.dessineCamembert()
        }
        tableViewEmissions.reloadData()
    }
    
    func dessineCamembert() {
        for subView in camembert.subviews {
            if subView is Graphique || subView is UILabel {
                subView.removeFromSuperview()
            }
        }
        var debut: CGFloat = 0.0
        let referenceRayon = max(emissionsCalculees, emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur)
        //        print(emissionsCalculees, emissionsSoutenables, emissionsCalculees / referenceRayon)
        var camembertVide: Bool = true
        let rayon = min(camembert.frame.width, camembert.frame.height) / 2 * 0.8 * sqrt(emissionsCalculees / referenceRayon)
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
                graphique.color = UIColor(morgenStemningNumber: numeroSection, MorgenStemningScaleSize: lesSections.count)
                graphique.draw(graphique.frame) //, debut: 0, etendue: 0.9)
                self.camembert.addSubview(graphique)
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
                self.camembert.addSubview(graphique2)
            } // if emission.valeur > 0
        } // for
        
        // écrire la légende des éléments principaux dans le camembert
        let emissionsClassees = lesEmissions.sorted(by: {$0.emission > $1.emission}).filter({$0.emission > 0})
        let limite = emissionsClassees.isEmpty ? 0.0 : emissionsClassees.count >= 5 ? emissionsClassees[4].emission : emissionsClassees.last?.emission ?? 0.0 // on affiche les 4 postes d'émission les plus importants, à condition qu'ils soient non-nuls
        if limite > 0 {
            debut = 0.0
            for emission in lesEmissions {
                let intervalle = emission.emission / emissionsCalculees
                if emission.emission >= limite && intervalle > 0.05 {
                    //            if emission.emission / emissionsCalculees > 0.05 {  // on n'affiche le nom des émissions que si elles sont au moins 5% du total
                    let largeurLabel = self.camembert.frame.width / 3
                    //                let fontSize = min(UIFont.systemFontSize, largeurLabel / 10.0)
                    let hauteurLabel = UIFont.systemFontSize
                    print("systemFontSize", UIFont.systemFontSize, largeurLabel)
                    
                    let positionAngulaireLabel = Double (2 * .pi * (debut + (intervalle / 2.0) - 0.25))
                    let positionX = CGFloat(self.camembert.frame.width + rayon * cos(positionAngulaireLabel) - largeurLabel) / 2.0
                    let positionY = CGFloat(self.camembert.frame.height + rayon * sin(positionAngulaireLabel) - hauteurLabel) / 2.0
                    let texte = UILabel(frame: CGRect(x: positionX, y: positionY, width: largeurLabel, height: hauteurLabel))
                    texte.numberOfLines = 1
                    texte.adjustsFontSizeToFitWidth = true
                    texte.textAlignment = .center
                    texte.text = emission.nomCourt
                    //                if #available(iOS 13.0, *) {
                    //                    texte.backgroundColor = .systemBackground.withAlphaComponent(0.2)
                    //                } else {
                    //                    texte.backgroundColor = .white.withAlphaComponent(0.2)
                    //                }
                    self.camembert.addSubview(texte)
                }
                debut = debut + intervalle
            }
        }
        // la référence de soutenabilité
        if !camembertVide {
            let graphique = Graphique()
            graphique.frame = CGRect(x: 0, y: 0, width: camembert.frame.width, height: camembert.frame.height) //camembert.frame //CGRect(x: 50, y: 100, width: 200, height: 200)
            graphique.radius = min(graphique.frame.width, graphique.frame.height) / 2 * 0.8 * sqrt(emissionsSoutenables * lesEmissions[SorteEmission.effectif.rawValue].valeur / referenceRayon)
            print(graphique.radius)
            graphique.trackWidth = min(graphique.frame.width, graphique.frame.height) / 50.0
            graphique.startPoint = 0.0
            graphique.fillPercentage = 1.0
            graphique.color = .green.withAlphaComponent(0.5) // UIColor(morgenStemningNumber: numeroSection, MorgenStemningScaleSize: lesSections.count)
            graphique.draw(graphique.frame) //, debut: 0, etendue: 0.9)
            camembert.addSubview(graphique)
        }
    }
    
    
    //    // method to run when table view cell is tapped
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        print("Cliqué sur la ligne \(indexPath.row).")
    //        //        modeFonctionnement = .recherche
    //        let lieu = lesLieuxPotentiels[indexPath.row]
    ////        if !lieu.latitude.isNaN {
    //            lieuAChercher = lieu
    //            demarrerModeRecherche()
    ////        } else {
    ////            tableView.cellForRow(at: indexPath)?.isSelected = false
    ////        }
    //    }
    
}

