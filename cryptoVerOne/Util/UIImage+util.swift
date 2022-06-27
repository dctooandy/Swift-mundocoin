//
//  UIImage+util.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import UIKit

extension UIImage {

    var withGrayscale: UIImage {
        guard let ciImage = CIImage(image: self, options: nil) else { return self }
        let paramsColor: [String: AnyObject] = [kCIInputBrightnessKey: NSNumber(value: 0.0), kCIInputContrastKey: NSNumber(value: 1), kCIInputSaturationKey: NSNumber(value: 0.25)]
        let grayscale = ciImage.applyingFilter("CIColorControls", parameters: paramsColor)
        guard let processedCGImage = CIContext().createCGImage(grayscale, from: grayscale.extent) else { return self }
        return UIImage(cgImage: processedCGImage, scale: scale, orientation: imageOrientation)
    }
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func gradientImage(with bounds: CGRect,
                              colors: [CGColor],
                              locations: [NSNumber]?) -> UIImage? {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        // This makes it horizontal
        gradientLayer.startPoint = CGPoint(x: 0.0,
                                           y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0,
                                         y: 0.5)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
    
    convenience init?(qrCode: String?, size: CGFloat) {
        
        //Fail if there is no text
        guard let qrCode = qrCode else { return nil }
        
        //Get self as data
        let stringData = qrCode.data(using: String.Encoding.utf8)
        
        //Generate CIImage
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(stringData, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        guard let ciImage = filter?.outputImage else { return nil }
        
        //Scale image to proper size
        let scale = size / ciImage.extent.size.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        //Convert to CGImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return nil }
        
        //Initialize with CGImage
        self.init(cgImage: cgImage)
    }
    func generateQRCode(from string: String, imageView: UIImageView, logo:UIImage?) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            // L: 7%, M: 15%, Q: 25%, H: 30%
            filter.setValue("M", forKey: "inputCorrectionLevel")
            
            if let qrImage = filter.outputImage {
                let scaleX = imageView.frame.size.width / qrImage.extent.size.width
                let scaleY = imageView.frame.size.height / qrImage.extent.size.height
                let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                var output = qrImage.transformed(by: transform)
                /// add logo
                if let logo = logo, let newImage =  addLogo(image: output, logo: logo) {
                    output = newImage
                }
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    private func addLogo(image: CIImage, logo: UIImage) -> CIImage? {
        
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        guard let logo = logo.cgImage else {
            return image
        }
        
        let ciLogo = CIImage(cgImage: logo)
        
        
        let centerTransform = CGAffineTransform(translationX: image.extent.midX - (ciLogo.extent.size.width / 2), y: image.extent.midY - (ciLogo.extent.size.height / 2))
        
        combinedFilter.setValue(ciLogo.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(image, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage
    }
    
    func blendedByColor(_ color: UIColor) -> UIImage {
        let scale = UIScreen.main.scale
        if scale > 1 {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        color.setFill()
        let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        let blendedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blendedImage!
    }
    func withColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        // 1
        let drawRect = CGRect(x: 0,y: 0,width: size.width,height: size.height)
        // 2
        color.setFill()
        UIRectFill(drawRect)
        // 3
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
    /**
     *  重设图片大小
     */
    func reSizeImage(reSize:CGSize)->UIImage
    {
        //UIGraphicsBeginImageContext(reSize);
        let imageView = UIImageView()
        imageView.frame =  CGRect(x: 0, y: 0, width: reSize.width, height: reSize.width)
        imageView.image = self
        imageView.contentMode = .scaleAspectFit
        var layer: CALayer = CALayer()
        layer = imageView.layer
//        layer.masksToBounds = true
//        layer.cornerRadius = 15.0
//        layer.borderWidth = 1.0
//        layer.borderColor = UIColor.lightGray.cgColor
        UIGraphicsBeginImageContext(imageView.bounds.size)
        
        //        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        //        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return roundedImage!;
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize:CGFloat)->UIImage
    {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
