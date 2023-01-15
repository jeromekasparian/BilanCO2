//
//  CelluleCredits.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 08/10/2022.
//

import Foundation
import UIKit

protocol CelluleVideDelegate: AnyObject {
}

class CelluleVide: UITableViewCell {
    
    weak var delegate: CelluleVideDelegate?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
}
