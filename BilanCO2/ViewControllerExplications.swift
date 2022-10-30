//
//  ViewControllerExplications.swift
//  Bilan CO2 camp scout
//
//  Created by Jérôme Kasparian on 28/10/2022.
//

import Foundation
import UIKit

var ligneExplicationsSelectionnee: Int = -1



let texteMethodo = "L'estimation des émissions de gaz à effet de serres, converties en équivalent CO₂, se base sur des facteurs d'émission moyens pour chaque catégorie, en fonction des pratiques les plus courantes sur un camp scout \n" +
"   • Repas : le calcul se concentre sur le déjeuner et le dîner, avec des facteurs d'émission moyens par type de repas. Il ne prend pas en compte les saisons, la distance des producteurs, le nombre d'intermédiaire, etc. \n" +
"   • Cuisson : il s'agit d'une estimation basée sur un temps de cuisson moyen, il ne prend pas en compte le détail des pratiques : usage des couvercles, protection contre le vent, tailles des casseroles, arrêt du gaz en fin de cuisson. Les repas qui ne sont pas cuisinés au gaz sont supposés cuits au feu de bois, avec un impact carbone nul. On considère en effet que dans une forêt gérée durablement, les arbres repoussent et stockent du carbone au même rythme qu'on en libère par la combustion du bois. À noter que ce raisonnement n'est valable qu'à long terme (30 ans). À court terme la combustion du bois dégage du CO₂. \n" +
"   • Transports et déplacements : les calculs supposent une taille \"moyenne\" pour les véhicules concernés. \n" +
"   • Hébergement : le calcul prend en compte un amortissement des tentes sur 5 ans et des marabouts sur 8 ans, sur la base de la composition typique des tentes de patrouille et marabouts de 12 m. Les locaux en dur sont supposés utilisés 4 mois par an (centre de vacances). \n" +
"   • Matériel : les émissions sont estimées sur la base des type de matériel généralement utilisé (outillage, matériel collectif de cuisine). L'essentiel des émissions vient du matériel en métal. Contrairement aux tentes, il n'est pas compté d'amortissement : les émissions des achats faits pour un camp sont attribuées à ce camp."

let texteGraphique = "Le graphique représente la répartition des émisssions de gaz à effet de serre dues au camp. \n" +
"Le cercle vert permet de les comparer avec les émissions acceptables pour préserver le climat : elles correspondent à 6,8 kg équivalent CO₂ par personne et par jour de camp."

let texteEmissionsAcceptables = "On estime que préserver le climat nécessite de limiter les émissions de gaz à effet de serre à 2,5 tonnes équivalent CO₂ par personne et par an, soit 6,8 kg équivalent CO₂ par personne et par jour de camp. Les émissions du camp sont ramenées au nombre de participants et à la durée du camp, puis comparées avec cette référence."

let texteLimites = "L'app permet d'estimer l'ordre de grandeur des principales émissions de gaz à effet de serre d'un camp scout : transports, alimentation, matériel collectif." +
"Elle ne prend notamment pas en compte \n" +
"   • les activités scoutes à l'année \n" +
"   • les émissions liées au matériel individuel des participants \n" +
"   • les émissions liées au transport des participants jusqu'au lieu de rendez-vous \n" +
"   • les émissions des participants qui ne sont pas liées au camp mais qui se poursuivent pendant celui-ci : leur domicile notamment. \n" +
"Pour une précision optimale, un bilan carbone complet par un organisme qualifié est indispensable. \n"

let texteSources =
"   • climatmundi, bilan carbone EEUdF, 2008 \n" +
"   • Ademe, bilans-ges.ademe.fr \n" +
"   • Carbone 4, www.carbone4.com/analyse-faq-voiture-electrique \n"

let texteRemerciements = "Éléonore Berger, Louise de Boysson, Suzanne Chevrel, Flore-Anne de Clermont, Daniel Hollaar, Hervé Kasparian, Agathe Lafont, Juliette Maupas, Roxane de Pol, Paul Manguy"


class Explications: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let lesParagraphes = ["Méthodologie & hypothèses", "Graphique", "Émissions acceptables pour préserver le climat", "Limites", "Sources", "Remerciements"]
    let lesTextes = [texteMethodo, texteGraphique, texteEmissionsAcceptables, texteLimites, texteSources, texteRemerciements]
    let cellReuseIdentifier = "celluleExplications"

    @IBOutlet var tableView: UITableView!
    @IBOutlet var boutonFermer: UIButton!
    @IBOutlet var boutonOK: UIButton!

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let texteSender = sender as? String ?? ""
//        print("texte Sender", texteSender)
//        if texteSender == texteAfficherExplicationsFigures {
//            ligneExplicationsSelectionnee = 1
//        }
//        super.prepare(for: segue, sender: sender)
//    }
    override func viewDidLoad(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)  // you don't need to register your UITableViewCell subclass if you're using prototype cells. -- https://stackoverflow.com/questions/37623281/swift-customizing-tableview-to-hold-multiple-columns-of-data
        if ligneExplicationsSelectionnee >= 0 {
            tableView.scrollToRow(at: IndexPath(row: ligneExplicationsSelectionnee, section: 0), at: .top, animated: true)
        }
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lesParagraphes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellReuseIdentifier)
        let ligne = indexPath.row
        cell.textLabel?.text = lesParagraphes[ligne]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .boldSystemFont(ofSize: 24)
        cell.detailTextLabel?.text = (ligneExplicationsSelectionnee == ligne) ? "\n" + lesTextes[ligne] : ""
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = .systemFont(ofSize: 18)
        cell.accessoryType = .none
        return cell
    }
    
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        print(indexPath.row)
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ligneExplicationsSelectionnee == indexPath.row { // on désélectionne la ligne qui était sélectionnée
            ligneExplicationsSelectionnee = -1
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else if ligneExplicationsSelectionnee == -1 { // aucune ligne n'était sélectionnée
            ligneExplicationsSelectionnee = indexPath.row
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } else {  // on avait une ligne sélectionnée et on en sélectionne une autre
            let ancienIndexPath = IndexPath(row: ligneExplicationsSelectionnee, section: 0)
            ligneExplicationsSelectionnee = indexPath.row
            tableView.reloadRows(at: [indexPath, ancienIndexPath], with: .automatic)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
//        print("Cliqué sur la ligne \(indexPath.row), ligne sélectionnée \(ligneExplicationsSelectionnee)")
//        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//        tableView.reloadData()
//        if ligneExplicationsSelectionnee >= 0 {
//        } else {
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//        }
    }
    
    @IBAction func fermerExplications() {
        self.dismiss(animated: true)
    }

}
