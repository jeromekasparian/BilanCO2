//
//  ViewController.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 04/09/2022.
//

// *** Priorite 1 ***
// AFFICHAGE / mise en page
// - fonction d'export
//      - message d'erreur extension pdf / "Extension request contains input items but the extension point does not specify a set of allowed payload classes. The extension point's NSExtensionContext subclass must implement `+_allowedItemPayloadClasses`. This must return the set of allowed NSExtensionItem payload classes. In future, this request will fail with an error." -- https://stackoverflow.com/questions/69528157/nsextension-warnings-when-uiactivityviewcontroller-selects-airdrop
// - problèmes positionnement : séquence contraintes / dessin camembert
//      - le camembert se cale en bas quand la vue est verticale très allongée -> tester sur iPad split view

// Explications
// - Daniel : les X jours soutenables sont ambigus quand c'est moins que la durée du camp -> retour en pourcentage
// - Daniel : swipe / tap pour basculer d'un affichage à l'autre (plusieurs manières de formuler la soutenabilité)

// *** Priorité 2 ***
// INTERFACE
// - le tableView passe sous le premier titre en haut (Mac en mode iPad seulement -- ok sur iphone/ipad et sur mac Catalyst)
// - Localisation, y compris les noms de types d'émission
// - export pdf : vectoriel plutôt que bitmap : cf code Hervé CreationPDF.swift

// *** A décider ***
// - supprimer le launcscreen ?
// - aspect du Grahpique / camembert : Hervé utilise le framework « charts » de Daniel Cohen Gindi & Philipp Jahoda https://github.com/danielgindi/Charts

// HERVE Logique d'usage
//Le ciblage des mesures à mettre en oeuvre relève en fait de l’enchainement de 2 étapes de raisonnement :
//1) priorisation (c’est dans la catégorie repas que je fais 60% de mes émissions)
//2) subsitution (je peux remplacer la viande rouge par du poisson blanc)
//
//Ton graph actuel ne permet pas voir ce qui se passe au sein d’une catégorie, donc il n’aide pas au 2)
//En revanche, il a une vrai valeur ajouté pour la priorisation. Donc j’en ferais sa fonction… et je supprimerais les sous-catégories.
//De toute façon si aujourd’hui j’y vais en Car, mon graph ne me montrera pas de catégorie Train, donc je ne verrais pas que "tiens le train c’est mieux que le car"
//
//Ce qui aide à la substitution, c’est le tableau lui même, en particulier :
//- le fait d’avoir lié le nombre de repas de chaque type, on voit vraiment que ça se substitue.
//
//Tu pourrais aller plus loin, et proposer des suggestions, tant que le bilan dépasse le 100%, genre une alerte
//- Les repas représente xx tonnes donc yy% de votre bilan carbonne, et si vous remplaciez 3 repas avec viande rouge par des repas végé ? [ok faisons ça] [as-tu une autre suggestion?]
//- les transports représente xx tonnes donc yy% de votre bilan carbonne, e et si vous y alliez en train plutôt qu’en car ? [ok faisons ça] [pas maintenant je vais déjà chercher un lieu moins loin de mon local][as-tu une autre suggestion ?]

//Aspect
//C'est déjà une police de la charte graphique, celle des titres.
//et une police plus « spécifique » à l’identité visuelle des EU ?
//Comme la pseudo-maniscrite :
//<Capture d’écran 2022-09-25 à 19.43.16.png>
//ou encore :
//Comfortaa
//pour les mots « Éclaireuses Éclaireurs UNIONISTES »
//
//Tekton Pro Bold
//pour les mots « de FRANCE »




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
let emissionsSoutenablesAnnuelles: Double = 2500.0 // t eq. CO2 / an / personne
var afficherPictos: Bool = true

enum Orientation {
    case inconnu
    case portrait
    case paysage
}

//enum LargeurCellule {
//    case inconnu
//    case large
//    case etroit
//}

class ViewController: ViewControllerAvecCamembert, UITableViewDelegate, UITableViewDataSource, CelluleEmissionDelegate, CelluleCreditsDelegate, UIPopoverControllerDelegate {
    
    // UIPopoverPresentationControllerDelegate, ConseilDelegate
    
    let keyValeursUtilisateurs = "keyValeursUtilisateurs"
    //    var camp = CaracteristiquesCamp()
    
    let cellReuseIdentifier = "CelluleEmission"
    let cellReuseIdentifierCredits = "CelluleCredits"
    var ligneEnCours: Int = -1
    var celluleEnCours: CelluleEmission! = nil
    var orientationGlobale: Orientation = .inconnu
    //    var largeurCellule: LargeurCellule = .inconnu
//    var timeStampDernierRedessin = Date()

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
        // mise en place de la détection du swipe left à 3 doigts pour activer le mode debug
        let swipePictos = UISwipeGestureRecognizer(target:self, action: #selector(changeModePictos))
        swipePictos.direction = UISwipeGestureRecognizer.Direction.left
        swipePictos.numberOfTouchesRequired = 3
        self.view.addGestureRecognizer(swipePictos)
        
        DispatchQueue.main.async {
            //            self.actualiseAffichageEmissions(grandFormat: false)
            
            self.tableViewEmissions.reloadData()
        }
    }  // viewDidLoad
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        redessineResultats(size: self.view.frame.size)
    }
    
    @objc func changeModePictos() {
        afficherPictos.toggle()
        DispatchQueue.main.async {
            self.dessineCamembert(camembert: self.camembert, grandFormat: false)
            self.tableViewEmissions.reloadData()
        }
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
        //        print("Cell for row at index path \(indexPath)")
        if indexPath.section < lesSections.count - 1 {  // les vraies données
            let emission = lesEmissions[numeroDeLigne(indexPath: indexPath)] //  lesEmissions.filter({$0.categorie == lesSections[indexPath.section]})[indexPath.row]
            let cell = tableViewEmissions.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CelluleEmission
            // set the text from the data model
            cell.delegate = self
            cell.choisitContraintes()
            cell.selectionStyle = .none
            if afficherPictos && !emission.picto.isEmpty {
                cell.labelNom.text = emission.picto + " " + emission.nom
            } else {
                cell.labelNom.text = emission.nom
            }
            if emission.echelleLog {
                cell.glissiere.minimumValue = Float(2.3)
                cell.glissiere.maximumValue = log(Float(emission.valeurMax))
                cell.glissiere.value = log(Float(emission.valeur))
            } else {
                cell.glissiere.minimumValue = emission.facteurEmission == 0 ? Float(1.0) : Float(0.0)
                cell.glissiere.maximumValue = Float(emission.valeurMax)
                cell.glissiere.value = Float(emission.valeur)
            }
            cell.labelValeur.text = String(format: self.formatAffichageValeur(valeurMax: emission.valeurMax) + emission.unite, emission.valeur).replacingOccurrences(of: " ", with: "\u{2007}") // on remplace les espaces par des blancs par des espaces de largeur fixe insécables
            cell.labelValeur.font = UIFont.monospacedDigitSystemFont(ofSize: cell.labelValeur.font.pointSize, weight: .regular)
            cell.actualiseEmissionIndividuelle(typeEmission: emission)
            //            let (texte, couleur) = texteEmissionsLigne(typeEmission: emission)
            //            cell.labelEmissionIndividuelle.text = texte
            //            cell.labelEmissionIndividuelle.textColor = couleur
            cell.boutonInfo.isHidden = emission.conseil.isEmpty
            cell.backgroundColor = couleursEEUdF6[indexPath.section].withAlphaComponent(0.4) // UIColor(morgenStemningNumber: indexPath.section, MorgenStemningScaleSize: lesSections.count).withAlphaComponent(0.5)
            cell.boutonInfo.setTitle("", for: .normal)
            return cell
        }
        else {  // la dernière section : les données
            let cell = tableViewEmissions.dequeueReusableCell(withIdentifier: cellReuseIdentifierCredits, for: indexPath) as! CelluleCredits
            cell.selectionStyle = .none
            cell.delegate = self
            cell.boutonOuvrirWeb.setTitle("", for: .normal)
            return cell
        }
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
    //        if indexPath.section == lesSections.count - 1 {
    //            return 150
    //        } else {
    //            return UITableView.automaticDimension
    //        }
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
        if lesSections[section] == "" {
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
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        let height: CGFloat = 48
    //        if #available(iOS 11.0, *) {
    //            tableView.estimatedSectionHeaderHeight = height
    //            return UITableView.automaticDimension
    //        } else {
    //            return height
    //        }
    //
    //    }
    
    
    func afficheConseil(cell: CelluleEmission){
        var message = ""
        if let indexPathDeLaCellule = tableViewEmissions.indexPath(for: cell) {
            message = lesEmissions[numeroDeLigne(indexPath:  indexPathDeLaCellule)].conseil //  cell.labelConseil.text
        }
        let alerte = UIAlertController(title: "Un conseil", message: message, preferredStyle: .alert)
        alerte.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "bouton OK"), style: .default, handler: nil))
        self.present(alerte, animated: true)
    }
    
    func debutMouvementGlissiere(cell: CelluleEmission){
        if celluleEnCours == nil {
            guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
                print("erreur index Path")
                return
            }
            //        tableViewEmissions.indexPathsForVisibleRows?.compactMap({if $0 != indexPath {
            //            tableViewEmissions.cellForRow(at: $0)?.resignFirstResponder()
            //        }})
            celluleEnCours = cell
            ligneEnCours = numeroDeLigne(indexPath: indexPath)
            //            print("Cellule en cours \(String(describing: celluleEnCours)), ligne \(ligneEnCours)")
        }
    }
    
    func glissiereBougee(cell: CelluleEmission) {
        
        //        guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
        //            print("erreur index Path")
        //            return
        //        }
        //        let ligne = numeroDeLigne(indexPath: indexPath)
        //        print("ligne \(ligne)")
        if ligneEnCours >= 0 && celluleEnCours != nil {
            DispatchQueue.main.async{
                let ligne = self.ligneEnCours
                let cellule = self.celluleEnCours
                let emission = lesEmissions[ligne]
                if emission.echelleLog {
                    if cellule!.glissiere.value == cellule!.glissiere.minimumValue {
                        lesEmissions[ligne].valeur = 0.0
                    } else {
                        lesEmissions[ligne].valeur = arrondi(exp(Double(cellule!.glissiere.value)))
                    }
                } else {
                    lesEmissions[ligne].valeur = Double(cellule!.glissiere.value)
                    if emission.valeurEntiere {
                        lesEmissions[ligne].valeur = round(lesEmissions[ligne].valeur)
                    }
                }
                cellule!.labelValeur.text = String(format: self.formatAffichageValeur(valeurMax: emission.valeurMax) + emission.unite, lesEmissions[ligne].valeur).replacingOccurrences(of: " ", with: "\u{2007}")
                switch ligne {
                case SorteEmission.duree.rawValue:
                    self.actualiseValeursMaxRepas(valeurMax: lesEmissions[SorteEmission.duree.rawValue].valeur)
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
                    self.actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
                default:
                    print("rien")
                }
                emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)
                cellule!.actualiseEmissionIndividuelle(typeEmission: lesEmissions[ligne])
//                if abs(self.timeStampDernierRedessin.timeIntervalSinceNow) > 1.0 {
                self.actualiseAffichageEmissions(grandFormat: false)
                    self.dessineCamembert(camembert: self.camembert, grandFormat: false)
//                    self.timeStampDernierRedessin = Date()
//                }
            }  // DispatchQueue.main.async
        } // if ligneEnCours >= 0 && celluleEnCours != nil
    }
        
    func finMouvementGlissiere(cell: CelluleEmission) {
        glissiereBougee(cell: cell)
        let lesValeurs = lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: keyValeursUtilisateurs)
        DispatchQueue.main.async{
            self.tableViewEmissions.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.ligneEnCours = -1
            self.celluleEnCours = nil
        }
    }
    
    
    func actualiseValeursMaxEffectif(valeurMax: Double) {
        for i in 0...lesEmissions.count-1 {
            if lesEmissions[i].valeurMaxSelonEffectif > 0 {
                let collerAuMax = lesEmissions[i].valeur == lesEmissions[i].valeurMax
                lesEmissions[i].valeurMax = valeurMax * lesEmissions[i].valeurMaxSelonEffectif
                if collerAuMax {
                    lesEmissions[i].valeur = lesEmissions[i].valeurMax
                } else {
                    lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
                }
            }
        }
    }
    
    func actualiseValeursMaxRepas(valeurMax: Double) {
        for i in 0...lesEmissions.count-1 {
            if lesEmissions[i].valeurMaxNbRepas > 0 {
                let collerAuMax = lesEmissions[i].valeur == lesEmissions[i].valeurMax
                lesEmissions[i].valeurMax = valeurMax * lesEmissions[i].valeurMaxNbRepas
                if collerAuMax {
                    lesEmissions[i].valeur = lesEmissions[i].valeurMax
                } else {
                    lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
                }
            }
        }
    }
    
    override func choisitContraintes(size: CGSize) -> Bool {
        let nouvelleOrientation: Orientation = size.width <= size.height ? .portrait : .paysage
        var change = false
        if nouvelleOrientation != orientationGlobale {
            let estModePortrait = nouvelleOrientation == .portrait
            orientationGlobale = nouvelleOrientation
            //        DispatchQueue.main.async {
            
            self.contrainteTableViewHautPortrait.isActive = estModePortrait
            self.contrainteTableViewDroitePortrait.isActive = estModePortrait
            self.contrainteVueResultatsGauchePortrait.isActive = estModePortrait
            
            self.contrainteTableViewHautPaysage.isActive = !estModePortrait
            self.contrainteTableViewDroitePaysage.isActive = !estModePortrait
            self.contrainteVueResultatsBasPaysage.isActive = !estModePortrait
            self.contrainteVueResultatGauchePaysage.isActive = !estModePortrait
            change = true
            //        }
        }
        let change2 = super.choisitContraintes(size: self.vueResultats.frame.size)
        return change || change2
    }
    
    
    func ouvrirWebEEUdF() {
        print("web")
        let adresse = "https://www.eeudf.org"
        if let url = URL(string: adresse), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
    func redessineResultats(size: CGSize) {
        DispatchQueue.main.async {
            let delai = self.choisitContraintes(size: size) ? 0.05 : 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delai) {
                self.actualiseAffichageEmissions(grandFormat: false)
                self.dessineCamembert(camembert: self.camembert, grandFormat: false)
            }
        }
        if celluleEnCours == nil { // pour ne pa
            tableViewEmissions.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = self.view.frame.size
        redessineResultats(size: size)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        redessineResultats(size: size)
    }
    
    
    
}

