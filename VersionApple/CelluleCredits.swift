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
}

class CelluleCredits: UITableViewCell {
    @IBOutlet var boutonOuvrirWeb: UIButton!
    @IBOutlet var labelCopyright: UILabel!
    @IBOutlet var boutonAdresseWeb: UIButton!
    @IBOutlet var imageLogo: UIImageView!
    
    weak var delegate: CelluleCreditsDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    

    @IBAction func ouvrirWebCredits() {
        self.delegate?.ouvrirWebCredits()
    }
    
}
