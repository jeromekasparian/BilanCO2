//
//  EmailSubjectActivityItemSource.swift
//  Twins
//
//  Created by Jérôme Kasparian on 15/02/2023.
//

// USAGE : A CHOISIR
// Si on veut avoir juste une pièce jointe et un subject, dans ce cas il faut changer la déclaration
// var emailBody: String
//pour mettre  Any à la place de String (et éventuellement changer le nom de la variable aussi) puis lors de l’appel mettre ça :
//if let urlPDFAExporter = generePDF() {
//            print("pdf ok")
//let emailTextAndSubject = EmailSubjectActivityItemSource(subject: leSujet, emailBody: urlPDFAExporter)
//items.append(emailTextAndSubject)
//            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
// source : Hervé via ChatGPT

import Foundation
import UIKit

class EmailSubjectActivityItemSource: NSObject, UIActivityItemSource {
    var subject: String
    var emailBody: String

    init(subject: String, emailBody: String) {
        self.subject = subject
        self.emailBody = emailBody
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return emailBody
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        if activityType == UIActivity.ActivityType.mail {
            return emailBody
        }
        return subject+"\n\n"+emailBody
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        if activityType == UIActivity.ActivityType.mail {
            return subject
        }
        return ""
    }
}

