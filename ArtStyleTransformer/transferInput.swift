//
//  transferInput.swift
//  ArtStyleTransformer
//
//  Created by terence on 2019/7/5.
//  Copyright © 2019年 terence. All rights reserved.
//

import UIKit
import CoreML

class transferInput: MLFeatureProvider {
    var input: CVPixelBuffer
    
    var featureNames: Set<String> {
        get {
            return ["img_placeholder__0"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "img_placeholder__0") {
            return MLFeatureValue(pixelBuffer: input)
        }
        return nil
    }
    
    init(input: CVPixelBuffer) {
        self.input = input
    }
}
