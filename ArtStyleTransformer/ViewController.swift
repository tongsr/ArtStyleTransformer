//
//  ViewController.swift
//  ArtStyleTransformer
//
//  Created by terence on 2019/7/5.
//  Copyright © 2019年 terence. All rights reserved.
//

import UIKit
import CoreML



class ViewController: UIViewController {
    public var imgTest = UIImage(named: "imgtest.jpeg")
    private var imgView = UIImageView.init()
    private let models = [
        wave().model,
        udnie().model,
        rain_princess().model,
        la_muse().model,
        StyleTransfer().model
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgView = UIImageView(image: self.imgTest)
        
        let screenSize = UIScreen.main.bounds.size
        self.imgView.frame=CGRect(origin: CGPoint(x:0,y:100), size: CGSize(width: screenSize.width, height: 300))
        self.view.addSubview(self.imgView)
        
        self.styleButtonTouched(style: 3)
    }


    private func styleButtonTouched(style: Int) {
        let image = self.imgTest?.cgImage
    
        let model = models[style]
    

        DispatchQueue.global(qos: .userInteractive).async {
            let stylized = self.stylizeImage(cgImage: image!, model: model, size: CGSize(width:883,height:720))
    
            DispatchQueue.main.async {
                let resultImage = UIImage(cgImage: stylized)
//                let imageview = UIImageView(image: resultImage)
//                imageview.frame=CGRect(origin: CGPoint(x:0,y:100), size: CGSize(width:375,height:300))
//                self.view.addSubview(imageview)
                
                self.imgView.image=resultImage
            }
        }
    }
    
    
    private func stylizeImage(cgImage: CGImage, model: MLModel,size:CGSize) -> CGImage {
        
        let buffer =  pixelBuffer(cgImage: cgImage, width: Int(size.width), height: Int(size.height))
        let provider = transferInput(input:buffer)
            

        
        let outFeatures = try! model.prediction(from: provider)

        let output = outFeatures.featureValue(for: "add_37__0")!.imageBufferValue!
        CVPixelBufferLockBaseAddress(output, .readOnly)
        let width = CVPixelBufferGetWidth(output)
        let height = CVPixelBufferGetHeight(output)
        let data = CVPixelBufferGetBaseAddress(output)!
        
        let outContext = CGContext(data: data,
                                   width: width,
                                   height: height,
                                   bitsPerComponent: 8,
                                   bytesPerRow: CVPixelBufferGetBytesPerRow(output),
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageByteOrderInfo.order32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)!
        let outImage = outContext.makeImage()!
        CVPixelBufferUnlockBaseAddress(output, .readOnly)
        
        return outImage
    }
    
    private func pixelBuffer(cgImage: CGImage, width: Int, height: Int) -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        if status != kCVReturnSuccess {
            fatalError("Cannot create pixel buffer for image")
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer!
    }
}

