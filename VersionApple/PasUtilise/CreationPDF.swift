////
////  CreationPDF.swift
////  Bilan CO2 camp scout
////
////  Created by Hervé Kasparian on 29/10/2022.
////
//
//import Foundation
//import UIKit
//
//class FirstViewController: UIViewController {
//
//   
//   
// 
//
//    func editPDF(Motif:Int) {
//        let font20 = UIFont.boldSystemFont(ofSize: 20)
//        let font11 = UIFont.systemFont(ofSize: 11)
//         let font7 = UIFont.systemFont(ofSize: 7)
//        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//                          paragraphStyle.alignment = NSTextAlignment.left
//        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
//
//        let textColor = UIColor.black
//
//        let textFontAttributes20 = [
//            NSAttributedString.Key.font: font20,
//                              NSAttributedString.Key.foregroundColor: textColor,
//                              NSAttributedString.Key.paragraphStyle: paragraphStyle
//                          ]
//       
//        let textFontAttributes7 = [
//                   NSAttributedString.Key.font: font7,
//                                     NSAttributedString.Key.foregroundColor: textColor,
//                                     NSAttributedString.Key.paragraphStyle: paragraphStyle]
//        let textFontAttributes11 = [
//        NSAttributedString.Key.font: font11,
//                          NSAttributedString.Key.foregroundColor: textColor,
//                          NSAttributedString.Key.paragraphStyle: paragraphStyle]
//        
//        
//        
//        let fileName = "CurrentAttestion.pdf"
//        
//               let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//               let documentsDirectory = paths[0] as NSString
//               let pathForPDF = documentsDirectory.appending("/" + fileName)
//        
//        
//        guard UIGraphicsBeginPDFContextToFile(pathForPDF, CGRect.zero, nil) else {
//            return
//        }
//        guard let destContext = UIGraphicsGetCurrentContext() else {
//            return
//        }
//        
//
//        let url = Bundle.main.url(forResource: "Attestation-q4", withExtension: "pdf")! as CFURL
//        let originalPDF:CGPDFDocument=CGPDFDocument(url)!
//        
//        
//        if let page = originalPDF.page(at: 1) {
//            var mediaBox = page.getBoxRect(.mediaBox)
//            destContext.beginPage(mediaBox: &mediaBox)
//            destContext.drawPDFPage(page)
//            destContext.textMatrix = .identity
//            destContext.translateBy(x: 0, y: mediaBox.height)
//               destContext.scaleBy(x: 1, y: -1)
//           
//            
//            var yDex:CGFloat=0
//            switch Motif{
//            case 0: yDex = 530//courses
//            case 1: yDex = 354//Sport
//            case 2:yDex = 575//Travail
//            case 3:yDex = 474//Santé
//            case 4:yDex = 433//Famille
//            case 5:yDex = 291//judiciaire
//            case 6:yDex = 252//mission
//            case 7: yDex = 207//école
//            case 8: yDex = 391//handicap
//            default :yDex = 0
//
//            }
//            let MyOrigin=mediaBox.height-17
//            let textRect = CGRect(x: 82, y: MyOrigin-(yDex+5), width: 19, height: 19)
//            
//            "x".draw(in: textRect, withAttributes: textFontAttributes20)
//            (Prenom+" "+Nom).draw(in: CGRect(x: 123, y: MyOrigin-690, width: 400, height: 22), withAttributes: textFontAttributes11)
//            DDN.Datestr.draw(in: CGRect(x: 123, y: MyOrigin-668, width: 300, height: 22), withAttributes: textFontAttributes11)
//            LieuDN.draw(in: CGRect(x: 300, y: MyOrigin-668, width: 300, height: 22), withAttributes: textFontAttributes11)
//             (Adresse+" "+CP+" "+Ville).draw(in: CGRect(x: 132, y: MyOrigin-644, width: 400, height: 32), withAttributes: textFontAttributes11)
//            Ville.draw(in: CGRect(x: 111, y: MyOrigin-170, width: 300, height: 19), withAttributes: textFontAttributes11)
//            Date().Datestr.draw(in: CGRect(x: 92, y: MyOrigin-146, width: 300, height: 19), withAttributes: textFontAttributes11)
//            (Date().Heurestr+" h "+Date().Minstr).draw(in: CGRect(x: 267, y: MyOrigin-146, width: 300, height: 19), withAttributes: textFontAttributes11)
//           // Date().Minstr.draw(in: CGRect(x: 320, y: MyOrigin-146, width: 300, height: 19), withAttributes: textFontAttributes11)
//           
//            
//            var GlobalString="Cree le: "+Date().DateAndTimestr+"; "+"Nom: "+Nom+"; "+"Prenom: "+Prenom+"; "+"Naissance: "+DDN.Datestr+" a "+LieuDN+"; "+"Adresse: "+Adresse+" "+CP+" "+Ville+"; "+"Sortie: "+Date().DateAndTimestr+"; "+"Motifs: "
//            
//            switch Motif{
//                case 0: GlobalString+="achats"
//                case 1: GlobalString+="sport_animaux"
//                case 2:GlobalString+="travail"
//                case 3:GlobalString+="sante"
//                case 4:GlobalString+="famille"
//                case 5:GlobalString+="convocation"
//                case 6:GlobalString+="missions"
//                case 7:GlobalString+="enfants"
//                case 8:GlobalString+="handicap"
//            default :do{}
//            }
//            print(GlobalString)
//            GlobalString=GlobalString.replacingOccurrences(of: "ʼ", with: "'")
//             GlobalString=GlobalString.replacingOccurrences(of:"’", with: "'")
//            print(GlobalString)
//                
//             GlobalString=GlobalString.folding(options: .diacriticInsensitive, locale: nil).onlyASCII()
//            print(GlobalString)
//            let MyQR=generateQRCode(from: GlobalString)! //ça génère une UIImage
//            
//            MyQR.draw(in: CGRect(x: mediaBox.width-170, y: MyOrigin-202, width: 100, height: 100))
//            "Date de création:".draw(in: CGRect(x: 463, y: MyOrigin-103, width: 300, height: 19), withAttributes: textFontAttributes7)
//            Date().DateAndTimestr.draw(in: CGRect(x: 450, y: MyOrigin-96, width: 300, height: 19), withAttributes: textFontAttributes7)
//            
//           
//           
//            
//            destContext.endPage()
//            
//            destContext.beginPage(mediaBox: &mediaBox)
//            destContext.textMatrix = .identity
//                       destContext.translateBy(x: 0, y: mediaBox.height)
//                          destContext.scaleBy(x: 1, y: -1)
//                   MyQR.draw(in: CGRect(x: 50, y: 50, width: 300, height: 300))
//                  
//            destContext.endPage()
//        }
//            
//
//        destContext.closePDF()
//        UIGraphicsEndPDFContext()
//        self.tabBarController?.selectedIndex =  1
//      
//        
//        
//    }
//   
//
//}
