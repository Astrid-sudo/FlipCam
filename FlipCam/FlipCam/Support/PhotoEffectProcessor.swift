//
//  PhotoEffectProcessor.swift
//  FlipCam
//
//  Created by Astrid Lin on 2025/3/25.
//

import UIKit

/// Guide Photo Effects
enum GuidePhotoEffect: String, CaseIterable, Identifiable {
	case normal = "Normal"
	case contrast = "Contrast"
	case inverse = "Inverse"
	case outline = "Outline"

	var id: String { rawValue }
}

struct PhotoEffectProcessor {
    static func processPhoto(_ photo: UIImage, with effect: GuidePhotoEffect) -> UIImage {
        guard let ciImage = CIImage(image: photo) else {
            logger.error("Failed to create CIImage from UIImage")
            return photo
        }
        
        switch effect {
        case .normal:
            return photo
            
        case .contrast:
            return applyContrastEffect(to: ciImage) ?? photo
            
        case .inverse:
            return applyInverseEffect(to: ciImage) ?? photo
            
        case .outline:
            return applyOutlineEffect(to: ciImage) ?? photo
        }
    }
    
    private static func applyContrastEffect(to image: CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        
        let parameters = [
            kCIInputImageKey: image,
            kCIInputContrastKey: NSNumber(value: 10.0),
            kCIInputBrightnessKey: NSNumber(value: 0.2)
        ] as [String : Any]
        
        guard let filter = CIFilter(name: "CIColorControls", parameters: parameters),
              let outputImage = filter.outputImage,
              let cgImg = context.createCGImage(outputImage, from: outputImage.extent) else {
            logger.error("Failed to apply contrast effect")
            return nil
        }
        
        return UIImage(cgImage: cgImg)
    }
    
    private static func applyInverseEffect(to image: CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        
        // First invert the colors
        guard let invertFilter = CIFilter(name: "CIColorInvert") else {
            logger.error("Failed to create CIColorInvert filter")
            return nil
        }
        invertFilter.setValue(image, forKey: kCIInputImageKey)
        
        guard let invertedImage = invertFilter.outputImage else {
            logger.error("Failed to get inverted image")
            return nil
        }
        
        // Then apply high contrast
        guard let contrastFilter = CIFilter(name: "CIColorControls") else {
            logger.error("Failed to create CIColorControls filter")
            return nil
        }
        contrastFilter.setValue(invertedImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(NSNumber(value: 10), forKey: kCIInputContrastKey)
        contrastFilter.setValue(NSNumber(value: -2), forKey: kCIInputBrightnessKey)
        contrastFilter.setValue(NSNumber(value: 1.2), forKey: kCIInputSaturationKey)
        
        guard let outputImage = contrastFilter.outputImage,
              let cgImg = context.createCGImage(outputImage, from: outputImage.extent) else {
            logger.error("Failed to get final inverse effect image")
            return nil
        }
        
        return UIImage(cgImage: cgImg)
    }
    
    private static func applyOutlineEffect(to image: CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        
        // First invert the colors
        guard let invertFilter = CIFilter(name: "CIColorInvert") else {
            logger.error("Failed to create CIColorInvert filter")
            return nil
        }
        invertFilter.setValue(image, forKey: kCIInputImageKey)
        
        guard let invertedImage = invertFilter.outputImage else {
            logger.error("Failed to get inverted image")
            return nil
        }
        
        // Increase contrast of inverted image
        guard let contrastFilter = CIFilter(name: "CIColorControls") else {
            logger.error("Failed to create CIColorControls filter")
            return nil
        }
        contrastFilter.setValue(invertedImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(NSNumber(value: 3.0), forKey: kCIInputContrastKey)
        contrastFilter.setValue(NSNumber(value: 0.0), forKey: kCIInputBrightnessKey)
        
        guard let contrastedImage = contrastFilter.outputImage else {
            logger.error("Failed to get contrasted image")
            return nil
        }
        
        // Apply edge detection
        guard let edgeFilter = CIFilter(name: "CIEdges") else {
            logger.error("Failed to create CIEdges filter")
            return nil
        }
        edgeFilter.setValue(contrastedImage, forKey: kCIInputImageKey)
        edgeFilter.setValue(NSNumber(value: 6.0), forKey: kCIInputIntensityKey)
        
        guard let edgeOutput = edgeFilter.outputImage else {
            logger.error("Failed to get edge detection output")
            return nil
        }
        
        // Make it brighter and increase contrast
        guard let brightnessFilter = CIFilter(name: "CIColorControls") else {
            logger.error("Failed to create final CIColorControls filter")
            return nil
        }
        brightnessFilter.setValue(edgeOutput, forKey: kCIInputImageKey)
        brightnessFilter.setValue(NSNumber(value: 8.0), forKey: kCIInputContrastKey)
        brightnessFilter.setValue(NSNumber(value: 0.3), forKey: kCIInputBrightnessKey)
        brightnessFilter.setValue(NSNumber(value: 0.0), forKey: kCIInputSaturationKey)
        
        guard let outputImage = brightnessFilter.outputImage,
              let cgImg = context.createCGImage(outputImage, from: outputImage.extent) else {
            logger.error("Failed to get final outline effect image")
            return nil
        }
        
        return UIImage(cgImage: cgImg)
    }
} 
