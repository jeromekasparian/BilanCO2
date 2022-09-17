//
//  Graphique.swift
//  BilanCO2
//
//  Created by Jérôme Kasparian on 08/09/2022.
//


import UIKit

class Graphique: UIView {
    
    var startPoint: CGFloat = 0
    var color: UIColor = UIColor.yellow
    var trackColor: UIColor = UIColor.gray
    var trackWidth: CGFloat = 1
    var fillPercentage: CGFloat = 1
    var radius: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 13.0, *) {
            self.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.0)
        } else {
            self.backgroundColor = .clear
            // Fallback on earlier versions
        }
    } // init
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.blue
    } // init
    
    private func getGraphStartAndEndPointsInRadians(debut: CGFloat, etendue: CGFloat) -> (graphStartingPoint: CGFloat, graphEndingPoint: CGFloat) {
        // debut et étendue en %
        return(CGFloat(2 * .pi * (debut - 0.25)), CGFloat(2 * .pi * (debut + etendue - 0.25)))
    } // func
    
    override func draw(_ rect: CGRect) {
        // first we want to find the centerpoint and the radius of our rect
        
        let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
        //        radius: CGFloat = rect.width / 2 * 0.8
        
        // we need our graph starting and ending points
        let (graphStartingPoint, graphEndingPoint) = self.getGraphStartAndEndPointsInRadians(debut: startPoint, etendue: fillPercentage)
        
        //    // now we need to first draw the track...
        //    let trackPath = UIBezierPath(arcCenter: center, radius: radius - (trackWidth / 2), startAngle: graphStartingPoint, endAngle: 2.0 * .pi, clockwise: true)
        //    trackPath.lineWidth = trackWidth
        //    self.trackColor.setStroke()
        //    trackPath.stroke()
        
        // now we can draw the progress arc
        let percentagePath = UIBezierPath(arcCenter: center, radius: radius - (trackWidth / 2), startAngle: graphStartingPoint, endAngle: graphEndingPoint, clockwise: true)
        percentagePath.lineWidth = trackWidth
        percentagePath.lineCapStyle = .butt
        self.color.setStroke()
        percentagePath.stroke()
        
    } // func
    
} // class


