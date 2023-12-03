//
//  CelluleCredits.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 08/10/2022.
//

import Foundation
import UIKit

protocol CelluleCreditsDelegate: AnyObject {
    func ouvrirWebCredits()
//    func finMouvementGlissiere(cell: CelluleEmission)
//    func afficheConseil(cell: CelluleEmission)
}

class CelluleCredits: UITableViewCell {
    @IBOutlet var boutonOuvrirWeb: UIButton!
    @IBOutlet var labelCopyright: UILabel!
    @IBOutlet var boutonAdresseWeb: UIButton!
    @IBOutlet var imageLogo: UIImageView!
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
    

    @IBAction func ouvrirWebCredits() {
        self.delegate?.ouvrirWebCredits()
    }
    
}
