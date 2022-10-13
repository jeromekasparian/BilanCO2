//
//  CelluleCredits.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 08/10/2022.
//

import Foundation
import UIKit

protocol CelluleCreditsDelegate: AnyObject {
    func ouvrirWebEEUdF()
    func finMouvementGlissiere(cell: CelluleEmission)
    func afficheConseil(cell: CelluleEmission)
}

class CelluleCredits: UITableViewCell {
    @IBOutlet var boutonOuvrirWeb: UIButton!
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
//    
////    weak var delegate: CelluleEmissionDelegate?
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
////        self.delegate = nil
//    }
    
    weak var delegate: CelluleCreditsDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    

    @IBAction func ouvrirWebEEUdF() {
        self.delegate?.ouvrirWebEEUdF()
    }
}
