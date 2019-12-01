//
//  ViewController.swift
//  arPeopleHighlight
//
//  Created by Andressa Valengo on 01/12/19.
//  Copyright © 2019 Andressa Valengo. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import VideoToolbox

class ViewController: UIViewController {
    
    private let character = ModelEntity()
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var segmentationImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        arView.session.delegate = self
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        
        let config = ARWorldTrackingConfiguration()
        config.frameSemantics = [.personSegmentation]
        arView.session.run(config)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let segmentationBuffer = frame.segmentationBuffer {
            if let image = UIImage(pixelBuffer: segmentationBuffer)?.rotate(radians: .pi / 2) {
                segmentationImageView.image = image
            }
        }
    }
}

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
    
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }
        return self
    }
}
