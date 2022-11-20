//
//  ViewControllerExplications.swift
//  Bilan CO2 camp scout
//
//  Created by Jérôme Kasparian on 28/10/2022.
//

import Foundation
import UIKit

var ligneExplicationsSelectionnee: Int = -1

let texteMethodo = NSLocalizedString("texteMethodo", comment: "")

let texteGraphique = NSLocalizedString("texteGraphique", comment: "")

let texteEmissionsAcceptables = NSLocalizedString("texteEmissionsAcceptables", comment: "")

let texteLimites = NSLocalizedString("texteLimites", comment: "")

let texteSources = NSLocalizedString("texteSources", comment: "")

let texteRemerciements = NSLocalizedString("texteRemerciements", comment: "")


class Explications: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let lesParagraphes = [NSLocalizedString("Méthodologie & hypothèses", comment: ""), NSLocalizedString("Graphique", comment: ""), NSLocalizedString("Émissions acceptables pour préserver le climat", comment: ""), NSLocalizedString("Limites", comment: ""), NSLocalizedString("Sources", comment: ""), NSLocalizedString("Remerciements", comment: "")]
    let lesTextes = [texteMethodo, texteGraphique, texteEmissionsAcceptables, texteLimites, texteSources, texteRemerciements]
    let cellReuseIdentifier = "celluleExplications"

    @IBOutlet var tableView: UITableView!
    @IBOutlet var boutonFermer: UIButton!
    @IBOutlet var boutonOK: UIButton!

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
    }
    
    @IBAction func fermerExplications() {
        self.dismiss(animated: true)
    }

}
