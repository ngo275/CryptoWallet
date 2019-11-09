//
//  QRCodeImageView.swift
//  CryptoWallet
//
//  Created by ShuichiNagao on 2019/11/10.
//  Copyright © 2019 Shuichi Nagao. All rights reserved.
//

import UIKit

class QRCodeImageView: UIImageView {

    private class func createQrImage(urlString: String) -> UIImage? {
        if urlString.isEmpty {
            return nil
        }
        guard let data = urlString.data(using: .utf8) else {
            return nil
        }
        
        let qrCode = CIFilter(name: "CIQRCodeGenerator", parameters:
            ["inputMessage": data as NSData,
             "inputCorrectionLevel": "H"])

        guard let outputImage = qrCode?.outputImage else {
            return nil
        }
        
        return UIImage(ciImage: outputImage)
    }
    
    func updateQrImage(urlString: String) {
        image = QRCodeImageView.createQrImage(urlString: urlString)
        
        if let qrImage = image {
            let resize = CGSize(width: frame.size.width, height: frame.size.height)
            
            UIGraphicsBeginImageContext(resize)
            let contextRef = UIGraphicsGetCurrentContext()
            
            contextRef!.interpolationQuality = .none
            qrImage.draw(in: CGRect(x: 0, y: 0, width: resize.width, height: resize.height))
            let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            image = resizeImage
            
            layer.magnificationFilter = CALayerContentsFilter.nearest
            contentMode = .scaleAspectFit
        }
        
    }
}

