//
//  ViewController.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 04/09/2022.
//

// *** Priorite 1 ***
// AFFICHAGE / mise en page
// - la page d'aide déborde parfois sur toute la largeur de l'écran.
// - prendre en charge le mode sombre ?
// - 

// Fonctionnalités
// - renvoyer vers des ressources
//      - Covoiturage : tableur en ligne de Matthieu - https://docs.google.com/spreadsheets/d/1OyeE4IQJVyMqPMOKvIPqD8eIR7lk0HiaE5yOCp02fvg/edit?usp=sharing
//      - autres ressources ?
// - transport : Ferry, train, bus : aussi sur place ?
// - activité : voile : cf données de Jérémy Balas
// - Autres activités ?

// Anomalies
// - fonction d'export
//      - message d'erreur extension pdf / "Extension request contains input items but the extension point does not specify a set of allowed payload classes. The extension point's NSExtensionContext subclass must implement `+_allowedItemPayloadClasses`. This must return the set of allowed NSExtensionItem payload classes. In future, this request will fail with an error." -- https://stackoverflow.com/questions/69528157/nsextension-warnings-when-uiactivityviewcontroller-selects-airdrop
//      - lors de l'export l'escamotage temporaire du bouton n'est pas très beau
//      - seul le PDF passe dans les messageries instantanées -> intégrer la liste au PDF
//      - format vectoriel plutôt que bitmap : cf code Hervé CreationPDF.swift
//      - formatter le texte d'accompagnement de l'export (titres notamment)


// *** A décider ***
// - aspect du grahpique / camembert : Hervé utilise le framework « charts » de Daniel Cohen Gindi & Philipp Jahoda https://github.com/danielgindi/Charts
// - Train et autres transports : allers simples ? - Thomas

//DÉCLINAISONS AUTRES ÉVÉNEMENTS
//Hervé : En ajoutant un tag dans les infos de la target, ensuite dans ton code tu indiques que tel bout de code n’est à compiler que si la target à tel tag. Et pour les fichiers de ressources (images, logo...) tu indiques dans quelle(s) target il fait les inclure. - J’avais fait pour Compétences lite/full. 
// - Conférence
// - Festival

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



import UIKit
//import AVFoundation

let largeurMiniGlissiere: CGFloat = 150
let emissionsSoutenablesAnnuelles: Double = 2000.0 // t eq. CO2 / an / personne
let facteurZoomGlissiere: Float = 10.0

//let notificationEmetteursChanges = "notificationEmetteursChanges"
let notificationBackground = "notificationBackground"
var emissionsCalculees: Double = .nan
var emissionsSoutenables: Double = .nan
var lesSections: [String] = []
//var effectif: Double = .nan
let userDefaults = UserDefaults.standard
//let largeurMiniTableViewEcranLarge: CGFloat = 400
var lesEmissions: [TypeEmission] = []
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

var ligneEnCours: Int = -1
//var premierAffichageApresInitialisation: Bool = true

class ViewController: ViewControllerAvecCamembert, UITableViewDelegate, UITableViewDataSource, CelluleEmissionDelegate, CelluleCreditsDelegate, UIPopoverControllerDelegate {
    
    // UIPopoverPresentationControllerDelegate, ConseilDelegate
    
    let keyValeursUtilisateurs = "keyValeursUtilisateurs"
    //    var camp = CaracteristiquesCamp()
    
    let cellReuseIdentifier = "CelluleEmission"
    let cellReuseIdentifierCredits = "CelluleCredits"
    var celluleEnCours: CelluleEmission! = nil
//    var orientationGlobale: Orientation = .inconnu
    //    var largeurCellule: LargeurCellule = .inconnu
//    var timeStampDernierRedessin = Date()
//    var bloquerLePassageEnModeZoom: Bool = false

    @IBOutlet var tableViewEmissions: UITableView!
    @IBOutlet var vueResultats: UIView!
    @IBOutlet var boutonEffacerDonnees: UIButton!
    @IBOutlet var boutonExport: UIButton!

    @IBOutlet var contrainteTableViewHautPortrait: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewHautPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewDroitePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteTableViewDroitePaysage: NSLayoutConstraint!
    
    @IBOutlet var contrainteVueResultatsGauchePortrait: NSLayoutConstraint!
    @IBOutlet var contrainteVueResultatsBasPaysage: NSLayoutConstraint!
    @IBOutlet var contrainteVueResultatGauchePaysage: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonEffacerLarge: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonExporterLarge: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonEffacerEtroit: NSLayoutConstraint!
    @IBOutlet var contrainteLargeurBoutonExporterEtroit: NSLayoutConstraint!

    override func viewDidLoad() {
        _ = self.choisitContraintes(size: self.view.frame.size)
        (lesEmissions, lesSections) = lireFichier(nom: "Data")
        let lesValeurs = userDefaults.value(forKey: keyValeursUtilisateurs) as? [Double] ?? []
        if !lesValeurs.isEmpty && lesValeurs.count == lesEmissions.count {
            for i in 0...lesValeurs.count - 1 {
                lesEmissions[i].valeur = lesValeurs[i]
            }
//            premierAffichageApresInitialisation = false
        }
        boutonEffacerDonnees.setTitle("", for: .normal) // ⌫  "\u{0232B}"
        boutonExport.setTitle("", for: .normal)

        actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
        ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
        emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)
        boutonExport.isHidden = emissionsCalculees == 0
        boutonEffacerDonnees.isHidden = emissionsCalculees == 0
        tableViewEmissions.delegate = self
        tableViewEmissions.dataSource = self
        if #available(iOS 15.0, *) {
            tableViewEmissions.sectionHeaderTopPadding = 0
        }
        // mise en place de la détection du swipe left à 3 doigts pour activer le mode debug
//        let swipePictos = UISwipeGestureRecognizer(target:self, action: #selector(changeModePictos))
//        swipePictos.direction = UISwipeGestureRecognizer.Direction.left
//        swipePictos.numberOfTouchesRequired = 3
//        self.view.addGestureRecognizer(swipePictos)
        
//        DispatchQueue.main.async {
            //            self.actualiseAffichageEmissions(grandFormat: false)
//            self.tableViewEmissions.reloadData()
//        }
        super.viewDidLoad()
    }  // viewDidLoad
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        DispatchQueue.main.async {
            self.redessineResultats(size: self.view.frame.size, curseurActif: false)
//        print("didappear")
//        tableViewEmissions.reloadData()
//        }
    }
    
    @objc func changeModePictos() {
        afficherPictos.toggle()
        DispatchQueue.main.async {
            self.dessineCamembert(camembert: self.camembert, grandFormat: false, curseurActif: false)
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
            cell.glissiere.thumbTintColor = .white // attention si couleur différentes pour l'animation ?
//            cell.labelValeur.text = String(format: self.formatAffichageValeur(valeurMax: emission.valeurMax) + emission.unite, emission.valeur).replacingOccurrences(of: " ", with: "\u{2007}") // on remplace les espaces par des blancs par des espaces de largeur fixe insécables
            cell.labelNom.text = texteNomValeurUnite(emission: emission, afficherPictos: afficherPictos)
            cell.labelValeur.isHidden = true // = texteValeurPourTableView(valeurMax: emission.valeurMax, unite: emission.unite, valeur: emission.valeur, afficherLoupe: false, tailleFonte: cell.labelValeur.font.pointSize)
//            cell.labelValeur.font = UIFont.monospacedDigitSystemFont(ofSize: cell.labelValeur.font.pointSize, weight: .regular)
            cell.actualiseEmissionIndividuelle(typeEmission: emission)
            cell.boutonInfo.isHidden = emission.conseil.isEmpty
            cell.backgroundColor = couleursEEUdF5[indexPath.section].withAlphaComponent(0.4) // UIColor(morgenStemningNumber: indexPath.section, MorgenStemningScaleSize: lesSections.count).withAlphaComponent(0.5)
            cell.boutonInfo.setTitle("", for: .normal)
//            cell.choisitContraintesCelluleEmission(largeurTableView: tableViewEmissions.frame.width)  // si on ne lui fournit pas la largeur du tableView, à la première exécution il a une largeur fausse pour certaines cellules.
            return cell
        }
        else {  // la dernière section : l'ours
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
        case 1: return "%1.0f"
        case 2: return "%2.0f"
        case 3: return "%3.0f"
        case 4: return "%4.0f"
        case 5: return "%5.0f"
        case 6: return "%6.0f"
        default: return "%.0f"
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
        headerView.backgroundColor = couleursEEUdF5[section] //UIColor(morgenStemningNumber: section, MorgenStemningScaleSize: lesSections.count) //.withAlphaComponent(0.7)
        
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
    
//    func texteValeurPourTableView(valeurMax: Double, unite: String, valeur: Double, afficherLoupe: Bool, tailleFonte: CGFloat) -> NSAttributedString {
//        let alpha = afficherLoupe ? 1.0 : 0.0
//        let couleurLoupe = UIColor.black.withAlphaComponent(alpha) // n'importe quelle couleur est ok en fait - du moins tant qu'on ne gère pas le mode sombre
//        let texteAAfficher = NSMutableAttributedString(string: "🔎", attributes: [NSAttributedString.Key.foregroundColor: couleurLoupe])
//        let texteValeurUnite =  NSAttributedString(string: String(format: self.formatAffichageValeur(valeurMax: valeurMax), valeur).replacingOccurrences(of: " ", with: "\u{2007}") + " " + unite, attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: tailleFonte, weight: .regular)])
//        texteAAfficher.append(texteValeurUnite)
//        return texteAAfficher as NSAttributedString
//    }
    
    var minValueEnCours: Float = .nan
    var maxValueEnCours: Float = .nan
    var valeurPrecedente: Float = .nan
    var couleurDefautThumb: UIColor = .white
    var glissiereModeZoom: Bool = false
//    var compteurCurseurImmobile: Int = 0
//    var dateDernierMouvementCurseur: Double = .nan
    
    func effacerDonnees() {
//        premierAffichageApresInitialisation = true
        for i in 0...lesEmissions.count - 1 {
            lesEmissions[i].valeur = 0.0 // lesEmissions[i].facteurEmission > 0 ? //0.0 : 1.0  // pour la durée et l'effectif, on met 1 par défaut, pas zéro
        }
        actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
        ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
        emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)
        boutonExport.isHidden = emissionsCalculees == 0
        boutonEffacerDonnees.isHidden = emissionsCalculees == 0
//        print("emissions Calculées : ", emissionsCalculees)
        let lesValeurs = lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: keyValeursUtilisateurs)
        
        DispatchQueue.main.async {
            self.tableViewEmissions.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.actualiseAffichageEmissions(grandFormat: false)
            self.dessineCamembert(camembert: self.camembert, grandFormat: false, curseurActif: false)
        }
    }
    
//    var dureeEstDejaZero: Bool = true
//    var effectifEstDejaZero: Bool = true

    func debutMouvementGlissiere(cell: CelluleEmission){
        print("debut mouvement glissière")
        if celluleEnCours == nil {
            guard let indexPath = self.tableViewEmissions.indexPath(for: cell) else {
                print("erreur index Path")
                return
            }
//            premierAffichageApresInitialisation = false
            celluleEnCours = cell
            ligneEnCours = numeroDeLigne(indexPath: indexPath)
            minValueEnCours = cell.glissiere.minimumValue
            maxValueEnCours = cell.glissiere.maximumValue
            valeurPrecedente = cell.glissiere.value
            couleurDefautThumb = cell.glissiere.thumbTintColor ?? .white
            glissiereModeZoom = false
//            compteurCurseurImmobile = 0
//            ligneTimerEnCoursPourZoom = -1
            cell.glissiere.isContinuous = true  // pour que le slider reçoive des mises à jour même s'il ne bouge pas : comportement par défaut sur MacOS, mais pas sur iOS
        }
    }
        
    func activerModeZoomGlissiere(ligne: Int, cellule: CelluleEmission, echelleLog: Bool) {
//        if (ligne == SorteEmission.duree.rawValue && cellule.glissiere.value == cellule.glissiere.minimumValue) || (ligne == SorteEmission.effectif.rawValue && cellule.glissiere.value == cellule.glissiere.minimumValue) {
//            self.alerteConfirmationReset()
//            self.finMouvementGlissiere(cell: cellule)
//        }
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
//        print("nouvel intervalle", cellule.glissiere.minimumValue, cellule.glissiere.value, cellule.glissiere.maximumValue)

    }

    func desactiverModeZoomGlissiere(ligne: Int, cellule: CelluleEmission) {
        cellule.glissiere.thumbTintColor = .white
        self.glissiereModeZoom = false
        cellule.glissiere.maximumValue = maxValueEnCours
        cellule.glissiere.minimumValue = minValueEnCours
    }

    
    func glissiereBougee(cell: CelluleEmission) {
        if ligneEnCours >= 0 && celluleEnCours != nil {
            print("glissiereBougee", celluleEnCours!.glissiere.value)
            let ligne = ligneEnCours
            let cellule = celluleEnCours
            let emission = lesEmissions[ligne]
            DispatchQueue.main.async{
                if !self.glissiereModeZoom && ((cellule!.glissiere.maximumValue - cellule!.glissiere.minimumValue) / facteurZoomGlissiere >= 3 || emission.echelleLog) {
                    let valeur = cellule!.glissiere.value
                    let ligneAuDebutDuTimer = ligne
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        if !self.mouvementGlissiereFini {
                            if ligneAuDebutDuTimer == ligne && abs(valeur - cellule!.glissiere.value) < 0.02 * (cellule!.glissiere.maximumValue - cellule!.glissiere.minimumValue) && !self.glissiereModeZoom {
                                self.activerModeZoomGlissiere(ligne: ligne, cellule: cellule!, echelleLog: emission.echelleLog)
//                                cellule!.labelValeur.text = //self.texteValeurPourTableView(valeurMax: emission.valeurMax, unite: emission.unite, valeur: emission.valeur, afficherLoupe: self.glissiereModeZoom, tailleFonte: cell.labelValeur.font.pointSize)
//                                cellule!.labelValeur.isHidden = false
                            }
//                        }
                    }
                }
                self.valeurPrecedente = cellule!.glissiere.value
                if emission.echelleLog {
                    if cellule!.glissiere.value == self.minValueEnCours { //  cellule!.glissiere.minimumValue {
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
//                cellule!.labelValeur.isHidden = !self.glissiereModeZoom
                cellule!.labelNom.text = texteNomValeurUnite(emission: emission, afficherPictos: afficherPictos)
//                cellule!.labelValeur.attributedText = self.texteValeurPourTableView(valeurMax: emission.valeurMax, unite: emission.unite, valeur: emission.valeur, afficherLoupe: self.glissiereModeZoom, tailleFonte: cell.labelValeur.font.pointSize)
                switch ligne {
                case SorteEmission.duree.rawValue:
                    self.ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
                case SorteEmission.repasViandeRouge.rawValue:
                    self.ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasViandeRouge, priorite2: SorteEmission.repasViandeBlanche, priorite3: SorteEmission.repasVegetarien)
                case SorteEmission.repasViandeBlanche.rawValue:
                    self.ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasViandeBlanche, priorite2: SorteEmission.repasViandeRouge, priorite3: SorteEmission.repasVegetarien)
                case SorteEmission.repasVegetarien.rawValue:
                    self.ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission.repasVegetarien, priorite2: SorteEmission.repasViandeRouge, priorite3: SorteEmission.repasViandeBlanche)
                case SorteEmission.effectif.rawValue:
                    self.actualiseValeursMaxEffectif(valeurMax: lesEmissions[SorteEmission.effectif.rawValue].valeur)
                default: let dummy = 1
                }
                emissionsCalculees = calculeEmissions(typesEmissions: lesEmissions)
                self.boutonExport.isHidden = emissionsCalculees == 0
                self.boutonEffacerDonnees.isHidden = emissionsCalculees == 0
                cellule!.actualiseEmissionIndividuelle(typeEmission: lesEmissions[ligne])
                var lesIndexPathAActualiser: [IndexPath] = []
                if let indexPathAActualiser = self.tableViewEmissions.indexPathForSelectedRow {
                    lesIndexPathAActualiser = [indexPathAActualiser]
                }
                self.tableViewEmissions.reloadRows(at: lesIndexPathAActualiser, with: .automatic)
                self.actualiseAffichageEmissions(grandFormat: false)
                self.dessineCamembert(camembert: self.camembert, grandFormat: false, curseurActif: true)
            }  // DispatchQueue.main.async
        } // if ligneEnCours >= 0 && celluleEnCours != nil
    }
        
    @IBAction func alerteConfirmationReset(){
        let alerte = UIAlertController(title: NSLocalizedString("Initialisation", comment: ""), message: NSLocalizedString("Effacer les données ?", comment: ""), preferredStyle: .alert)
        alerte.addAction(UIAlertAction(title: NSLocalizedString("Annuler", comment: ""), style: .default, handler: nil))
        alerte.addAction(UIAlertAction(title: NSLocalizedString("Effacer", comment: ""), style: .destructive, handler: {_ in self.effacerDonnees()}))
        self.present(alerte, animated: true)

    }
    func ajusteMaxEtQuantiteRepasParType(priorite1: SorteEmission, priorite2: SorteEmission, priorite3: SorteEmission) {
        let nombreJours = lesEmissions[SorteEmission.duree.rawValue].valeur
        actualiseValeursMaxRepas(valeurMax: nombreJours)
        lesEmissions[priorite1.rawValue].valeur = min(lesEmissions[priorite1.rawValue].valeur, nombreJours * 2)
        lesEmissions[priorite2.rawValue].valeur = min(lesEmissions[priorite2.rawValue].valeur, nombreJours * 2 - lesEmissions[priorite1.rawValue].valeur)
        lesEmissions[priorite3.rawValue].valeur = nombreJours * 2 - lesEmissions[priorite1.rawValue].valeur - lesEmissions[priorite2.rawValue].valeur
    }
    
    func finMouvementGlissiere(cell: CelluleEmission) {
        print("fin mouvement glissière")
        glissiereBougee(cell: cell)
        let lesValeurs = lesEmissions.map({$0.valeur})
        userDefaults.set(lesValeurs, forKey: keyValeursUtilisateurs)
        cell.glissiere.minimumValue = minValueEnCours
        cell.glissiere.maximumValue = maxValueEnCours
        glissiereModeZoom = false
//        compteurCurseurImmobile = 0
//        mouvementGlissiereFini = true
        DispatchQueue.main.async{
            cell.glissiere.thumbTintColor = self.couleurDefautThumb
            self.tableViewEmissions.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ligneEnCours = -1
            self.celluleEnCours = nil
            self.dessineCamembert(camembert: self.camembert, grandFormat: false, curseurActif: false)
        }
    }
    
    
    func actualiseValeursMaxEffectif(valeurMax: Double) {
        for i in 0...lesEmissions.count-1 {
            if lesEmissions[i].valeurMaxSelonEffectif > 0 {
                let collerAuMax = lesEmissions[i].valeur == lesEmissions[i].valeurMax && lesEmissions[i].valeurMax > 0.0
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
                let collerAuMax = lesEmissions[i].valeur == lesEmissions[i].valeurMax && lesEmissions[i].valeurMax > 0.0
                lesEmissions[i].valeurMax = valeurMax * lesEmissions[i].valeurMaxNbRepas
                if collerAuMax {
                    lesEmissions[i].valeur = lesEmissions[i].valeurMax
                } else {
                    lesEmissions[i].valeur = min(lesEmissions[i].valeur, lesEmissions[i].valeurMax)
                }
            }
        }
    }
    
    func dessineBoutons(ecranLarge: Bool){
        let taille: CGFloat = ecranLarge ? 20 : 14
        if #available(iOS 13.0, *) {
            boutonExport.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: taille)), for: .normal)
            boutonEffacerDonnees.setImage(UIImage(systemName: "delete.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: taille)), for: .normal)
        } else {
            boutonExport.setImage(UIImage(named: "square.and.arrow.up"), for: .normal) //, withConfiguration: UIImage.SymbolConfiguration(pointSize: taille)), for: .normal)
            boutonEffacerDonnees.setImage(UIImage(named: "delete.left"), for: .normal) //, withConfiguration: UIImage.SymbolConfiguration(pointSize: taille)), for: .normal)
        }
    }
    
    
    override func choisitContraintes(size: CGSize) -> Bool {
//        print("choisitContraintes")
        let nouvelleOrientation: Orientation = size.width <= size.height ? .portrait : .paysage
        var change = false
//        if nouvelleOrientation != orientationGlobale {
//            let estModePortrait = nouvelleOrientation == .portrait
//            orientationGlobale = nouvelleOrientation
//            print("choisit contraintes, orientation", nouvelleOrientation)
//            if estModePortrait {  // on désactive avant d'activer pour éviter les conflits
            if nouvelleOrientation == .portrait && self.contrainteTableViewHautPaysage.isActive {
                self.contrainteTableViewHautPaysage.isActive = false
                self.contrainteTableViewDroitePaysage.isActive = false
                self.contrainteVueResultatsBasPaysage.isActive = false
                self.contrainteVueResultatGauchePaysage.isActive = false

                self.contrainteTableViewHautPortrait.isActive = true
                self.contrainteTableViewDroitePortrait.isActive = true
                self.contrainteVueResultatsGauchePortrait.isActive = true
                change = true
            } else if nouvelleOrientation == .paysage && self.contrainteTableViewHautPortrait.isActive {
                self.contrainteTableViewHautPortrait.isActive = false
                self.contrainteTableViewDroitePortrait.isActive = false
                self.contrainteVueResultatsGauchePortrait.isActive = false
                
                self.contrainteTableViewHautPaysage.isActive = true
                self.contrainteTableViewDroitePaysage.isActive = true
                self.contrainteVueResultatsBasPaysage.isActive = true
                self.contrainteVueResultatGauchePaysage.isActive = true
                change = true
            }
//        }
        let ecranLarge = self.vueResultats.frame.width >= 600
        if ecranLarge {  // réduire la taille des boutons si on a un écran étroit.
            self.contrainteLargeurBoutonEffacerEtroit.isActive = false
            self.contrainteLargeurBoutonExporterEtroit.isActive = false
            self.contrainteLargeurBoutonEffacerLarge.isActive = true
            self.contrainteLargeurBoutonExporterLarge.isActive = true
        } else {
            self.contrainteLargeurBoutonEffacerLarge.isActive = false
            self.contrainteLargeurBoutonExporterLarge.isActive = false
            self.contrainteLargeurBoutonEffacerEtroit.isActive = true
            self.contrainteLargeurBoutonExporterEtroit.isActive = true
        }
        dessineBoutons(ecranLarge: ecranLarge)
//        print("largeurResultats", self.vueResultats.frame.width)
        let change2 = super.choisitContraintes(size: self.vueResultats.frame.size)
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
                self.actualiseAffichageEmissions(grandFormat: false)
                self.dessineCamembert(camembert: self.camembert, grandFormat: false, curseurActif: curseurActif)
            }
        }
        if celluleEnCours == nil { // pour ne pa
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
        print("sender", sender)
//        self.boutonExport.isHidden = true
//        self.boutonAideGraphique.isHidden = true
        let vueAExporter = vueResultats!
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
        let activityViewController = UIActivityViewController(activityItems: [NSAttributedString(string: NSLocalizedString("Les émissions de CO₂ de mon camp", comment: ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.systemFontSize * 2)]), texteListeEmissions(lesEmissions: lesEmissions), saveFileURL], applicationActivities: nil) // "" : le corps du message intégré automatiquement
#if targetEnvironment(macCatalyst)
        //"Don't do this !!"
#else
        activityViewController.setValue(NSLocalizedString("Impact climat de mon camp", comment: ""), forKey: "subject")
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
            popover.permittedArrowDirections = .any
            popover.sourceView = sender // sender;
//            popover.delegate = self
//            popover.sourceRect = sender.frame //sender.frame;
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    
}

