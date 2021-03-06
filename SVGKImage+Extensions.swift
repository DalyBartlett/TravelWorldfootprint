//
//  SVGKImage+Extensions.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/9/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

extension SVGKImage {
    
    @available(iOS 10.0, *)
    func colorVisitedCounties(for user: User) {
        let countriesLayers = self.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
        
        for layer in countriesLayers {
            layer.fillColor = UIColor.countryDefaultColor.cgColor
        }
        
        let visitedCountriesLayers = countriesLayers.filter { (layer) in
            user.visitedCountriesArray.contains(where: { $0.code == layer.name! })
        }
        
        for layer in visitedCountriesLayers {
            layer.fillColor = UIColor.blueTraverColor.cgColor
        }
    }
    
}
