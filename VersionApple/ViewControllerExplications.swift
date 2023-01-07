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
//    let lesParagraphes = [NSLocalizedString("Méthodologie & hypothèses", comment: ""), NSLocalizedString("Graphique", comment: ""), NSLocalizedString("Émissions acceptables pour préserver le climat", comment: ""), NSLocalizedString("Limites", comment: ""), NSLocalizedString("Sources", comment: ""), NSLocalizedString("Remerciements", comment: "")]
//    let lesTextes = [texteMethodo, texteGraphique, texteEmissionsAcceptables, texteLimites, texteSources, texteRemerciements]
    let lesTextes = [texteMethodo, texteEmissionsAcceptables, texteLimites, texteSources, texteRemerciements]
    let lesParagraphes = [NSLocalizedString("Méthodologie & hypothèses", comment: ""), NSLocalizedString("Émissions acceptables pour préserver le climat", comment: ""), NSLocalizedString("Limites", comment: ""), NSLocalizedString("Sources", comment: ""), NSLocalizedString("Remerciements", comment: "")]

    let cellReuseIdentifier = "celluleExplications"
    var lesTextesFormattes: [NSAttributedString] = []

    @IBOutlet var tableView: UITableView!
    @IBOutlet var boutonFermer: UIButton!
    @IBOutlet var boutonOK: UIButton!
//    @IBOutlet var labelTest: UILabel!
    
    override func viewDidLoad(){
//        labelTest.attributedText = formateTexte(texte: NSLocalizedString("texteSources", comment: ""))
        lesTextesFormattes = lesTextes.map({formateTexte(texte: "\n" + $0)})
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)  // you don't need to register your UITableViewCell subclass if you're using prototype cells. -- https://stackoverflow.com/questions/37623281/swift-customizing-tableview-to-hold-multiple-columns-of-data
        if ligneExplicationsSelectionnee >= 0 && lesParagraphes.count > ligneExplicationsSelectionnee {
            tableView.scrollToRow(at: IndexPath(row: ligneExplicationsSelectionnee, section: 0), at: .top, animated: true)
        }
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    if ligneExplicationsSelectionnee >= 0 && lesParagraphes.count > ligneExplicationsSelectionnee {
        tableView.scrollToRow(at: IndexPath(row: ligneExplicationsSelectionnee, section: 0), at: .top, animated: true)
    }
        super.viewDidAppear(animated)
}
    
    func formateTexte(texte: String, marqueur: String, format: [NSAttributedString.Key : Any]) -> NSAttributedString? {
        let longueurMarqueur = marqueur.count
        let lesIndices = texte.indicesOf(string: marqueur)
        let nombreOccurrences = lesIndices.count / 2
        let texteSansMarqueurs = texte.replacingOccurrences(of: marqueur, with: "")
        let texteFormate = NSMutableAttributedString(string: texteSansMarqueurs, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        if nombreOccurrences > 0 {
            for i in 0...nombreOccurrences - 1 {
                texteFormate.addAttributes(format, range: NSRange(location: lesIndices[2 * i] - 2 * longueurMarqueur * i, length: lesIndices[2 * i + 1] - lesIndices[2 * i] - longueurMarqueur))   // symbolicTraits: [.traitBold, .traitItalic]
            }
            return texteFormate as NSAttributedString
        } else {
            return nil
        }
    }
    
    func formateTexte(texte: String) -> NSAttributedString {
        if let texteFormatte = formateTexte(texte: texte, marqueur: "***", format: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18).boldItalics()]) {
            return texteFormatte
        } else {
//        https://stackoverflow.com/questions/21629784/how-can-i-make-a-clickable-link-in-an-nsattributedstring
            return formateTexte(texte: texte, marqueur: "@@", format: [NSAttributedString.Key.link: "https://www.eeudf.org"]) ?? NSAttributedString(string: "")
        }
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
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.attributedText = (ligneExplicationsSelectionnee == ligne) && lesTextesFormattes.count > ligne ? lesTextesFormattes[ligne] : NSAttributedString(string: "")
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
        } else if lesParagraphes.count > ligneExplicationsSelectionnee {  // on avait une ligne sélectionnée et on en sélectionne une autre -- on vérifie qu'on est bien dans le tableau
            let ancienIndexPath = IndexPath(row: ligneExplicationsSelectionnee, section: 0)
            ligneExplicationsSelectionnee = indexPath.row
            tableView.reloadRows(at: [indexPath, ancienIndexPath], with: .automatic)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } else {
            ligneExplicationsSelectionnee = -1
        }
    }
    
    @IBAction func fermerExplications() {
        self.dismiss(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        ligneExplicationsSelectionnee = -1
//        print("disappear")
        super.viewWillDisappear(animated)
    }

}


extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

// https://stackoverflow.com/questions/34499735/how-to-apply-bold-and-italics-to-an-nsmutableattributedstring-range
extension UIFont {

    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {

        // create a new font descriptor with the given traits
        guard let fd = fontDescriptor.withSymbolicTraits(traits) else {
            // the given traits couldn't be applied, return self
            return self
        }
            
        // return a new font with the created font descriptor
        return UIFont(descriptor: fd, size: pointSize)
    }

    func italics() -> UIFont {
        return withTraits(.traitItalic)
    }

    func bold() -> UIFont {
        return withTraits(.traitBold)
    }

    func boldItalics() -> UIFont {
        return withTraits([ .traitBold, .traitItalic ])
    }
}
