//
//  ViewControllerExplications.swift
//  Bilan CO2 camp scout
//
//  Created by Jérôme Kasparian on 28/10/2022.
//

import Foundation
import UIKit

var ligneExplicationsSelectionnee: Int = -1




class Explications: UIViewController, UITableViewDelegate, UITableViewDataSource, CelluleExplicationsDelegate {

    let cellReuseIdentifier = "celluleExplications"
    var lesTextesFormattes: [NSAttributedString] = []

    @IBOutlet var tableView: UITableView!
    @IBOutlet var boutonFermer: UIButton!
    @IBOutlet var boutonOK: UIButton!
    @IBOutlet var imageRondVertNO: UIImageView!
    @IBOutlet var imageRondVertNE: UIImageView!
    @IBOutlet var imageRondVertSO: UIImageView!
    @IBOutlet var imageRondVertSE: UIImageView!
        
    override func viewDidLoad(){
        boutonFermer.setTitle("", for: .normal)
        lesTextesFormattes = lesTextes.map({formateTexte(texte: $0)})
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)  // you don't need to register your UITableViewCell subclass if you're using prototype cells. -- https://stackoverflow.com/questions/37623281/swift-customizing-tableview-to-hold-multiple-columns-of-data
        if ligneExplicationsSelectionnee >= 0 && lesParagraphes.count > ligneExplicationsSelectionnee {
            tableView.scrollToRow(at: IndexPath(row: ligneExplicationsSelectionnee, section: 0), at: .top, animated: true)
        }
        imageRondVertNE.isHidden = lEvenement.evenement != .camp
        imageRondVertNO.isHidden = lEvenement.evenement != .camp
        imageRondVertSE.isHidden = lEvenement.evenement != .camp
        imageRondVertSO.isHidden = lEvenement.evenement != .camp
        
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
            return NSAttributedString(string: texte, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lesParagraphes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CelluleExplications
        let ligne = indexPath.row
        cell.titre.textContainer.heightTracksTextView = true
        cell.titre.text = lesParagraphes[ligne]
        cell.titre.font = .boldSystemFont(ofSize: 24)
        cell.titre.textContainer.heightTracksTextView = true
        if (ligneExplicationsSelectionnee == ligne) && lesTextesFormattes.count > ligne {
            cell.texte.attributedText = lesTextesFormattes[ligne]
            cell.contrainteEcraserTexte.isActive = false
        } else {
            cell.texte.text = ""
            cell.contrainteEcraserTexte.isActive = true
        }
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
        super.viewWillDisappear(animated)
    }

}
