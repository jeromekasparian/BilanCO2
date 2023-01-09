//
//  CelluleCredits.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 08/10/2022.
//

import Foundation
import UIKit

protocol CelluleExplicationsDelegate: AnyObject {
}

class CelluleExplications: UITableViewCell {
    @IBOutlet var titre: UITextView!
    @IBOutlet var texte: UITextView!
    
    weak var delegate: CelluleExplicationsDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
}
