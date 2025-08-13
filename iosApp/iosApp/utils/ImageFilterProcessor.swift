//
//  ImageFilterProcessor.swift
//  iosApp
//
//  Created by Mohsin on 11/08/2025.
//  Copyright © 2025 orgName. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import shared

class ImageFilterProcessor {
    
    private let context = CIContext()
    
    func applyFilters(to image: UIImage, filters: [Filter], maxSize: Int? = nil) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let ciImage = CIImage(image: image) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                var processedImage = ciImage
                
                // Apply filters
                for filter in filters {
                    processedImage = self.applyFilter(filter.type, to: processedImage) ?? processedImage
                }
                
                // Apply vignette for certain filters
                let vignetteFilters: [FilterType] = [.lomo, .amaro, .xproii, .lofi, .toaster, .hudson]
                if filters.contains(where: { vignetteFilters.contains($0.type) }) {
                    processedImage = self.applyVignette(to: processedImage) ?? processedImage
                }
                
                // Convert back to UIImage
                guard let cgImage = self.context.createCGImage(processedImage, from: processedImage.extent) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                var resultImage = UIImage(cgImage: cgImage)
                
                // Resize if needed
                if let maxSize = maxSize {
                    resultImage = self.resizeImage(resultImage, maxSize: maxSize)
                }
                
                continuation.resume(returning: resultImage)
            }
        }
    }
    
    private func applyFilter(_ filterType: FilterType, to image: CIImage) -> CIImage? {
        switch filterType {
        case .reset:
            return image
            
        case .vintage:
            return applyVintageFilter(to: image)
            
        case .lomo:
            return applyLomoFilter(to: image)
            
        case .clarendon:
            return applyClarendonFilter(to: image)
            
        case .valencia:
            return applyValenciaFilter(to: image)
            
        case .amaro:
            return applyAmaroFilter(to: image)
            
        case .gingham:
            return applyGinghamFilter(to: image)
            
        case .juno:
            return applyJunoFilter(to: image)
            
        case .moon:
            return applyMoonFilter(to: image)
            
        case .nashville:
            return applyNashvilleFilter(to: image)
            
        case .xproii:
            return applyXProIIFilter(to: image)
            
        case .lofi:
            return applyLoFiFilter(to: image)
            
        case .toaster:
            return applyToasterFilter(to: image)
            
        case .hudson:
            return applyHudsonFilter(to: image)
            
        case .perpetua:
            return applyPerpetuaFilter(to: image)
            
        case .mayfair:
            return applyMayfairFilter(to: image)
        }
    }
    
    // MARK: - Individual Filter Implementations
    
    private func applyVintageFilter(to image: CIImage) -> CIImage? {
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = image
        colorMatrix.rVector = CIVector(x: 0.9, y: 0.5, z: 0.1, w: 0)
        colorMatrix.gVector = CIVector(x: 0.3, y: 0.8, z: 0.1, w: 0)
        colorMatrix.bVector = CIVector(x: 0.1, y: 0.3, z: 0.7, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.078, y: 0.078, z: 0, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyLomoFilter(to image: CIImage) -> CIImage? {
        guard let saturationFilter = applySaturation(to: image, saturation: 1.5) else { return nil }
            
            let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = saturationFilter
        colorMatrix.rVector = CIVector(x: 1.4, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.4, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.4, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: -0.078, y: -0.078, z: -0.078, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyClarendonFilter(to image: CIImage) -> CIImage? {
        guard let saturationFilter = applySaturation(to: image, saturation: 1.2) else { return nil }
            
            let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = saturationFilter
        colorMatrix.rVector = CIVector(x: 1.2, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.2, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.3, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.039, y: 0.039, z: 0, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyValenciaFilter(to image: CIImage) -> CIImage? {
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = image
        colorMatrix.rVector = CIVector(x: 1.0, y: 0.2, z: 0.1, w: 0)
        colorMatrix.gVector = CIVector(x: 0.1, y: 1.0, z: 0.1, w: 0)
        colorMatrix.bVector = CIVector(x: 0.1, y: 0.1, z: 0.9, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.078, y: 0.078, z: 0, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyAmaroFilter(to image: CIImage) -> CIImage? {
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = image
        colorMatrix.rVector = CIVector(x: 1.1, y: 0.2, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.1, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.0, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.118, y: 0.078, z: 0.039, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyGinghamFilter(to image: CIImage) -> CIImage? {
        guard let saturationFilter = applySaturation(to: image, saturation: 0.8) else { return nil }
            
            let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = saturationFilter
        colorMatrix.rVector = CIVector(x: 1.1, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.1, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.0, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.078, y: 0.078, z: 0.039, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyJunoFilter(to image: CIImage) -> CIImage? {
        guard let saturationFilter = applySaturation(to: image, saturation: 1.3) else { return nil }
            
            let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = saturationFilter
        colorMatrix.rVector = CIVector(x: 1.2, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.2, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.1, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.059, y: 0.039, z: 0.020, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyMoonFilter(to image: CIImage) -> CIImage? {
        guard let grayscaleFilter = applyGrayscale(to: image) else {return nil}
        
              let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = grayscaleFilter
        colorMatrix.rVector = CIVector(x: 1.2, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.2, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.2, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.039, y: 0.039, z: 0.039, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyNashvilleFilter(to image: CIImage) -> CIImage? {
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = image
        colorMatrix.rVector = CIVector(x: 0.8, y: 0.4, z: 0.2, w: 0)
        colorMatrix.gVector = CIVector(x: 0.2, y: 0.9, z: 0.2, w: 0)
        colorMatrix.bVector = CIVector(x: 0.1, y: 0.1, z: 0.8, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.118, y: 0.078, z: 0.039, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyXProIIFilter(to image: CIImage) -> CIImage? {
        guard let saturationFilter = applySaturation(to: image, saturation: 1.1) else { return nil }
            
            let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = saturationFilter
        colorMatrix.rVector = CIVector(x: 1.0, y: 0, z: 0.2, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.0, z: 0.2, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0.2, z: 1.2, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.039, y: 0.039, z: 0, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyLoFiFilter(to image: CIImage) -> CIImage? {
        guard let saturationFilter = applySaturation(to: image, saturation: 1.4) else { return nil }
            
            let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = saturationFilter
        colorMatrix.rVector = CIVector(x: 1.5, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.5, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.5, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: -0.118, y: -0.118, z: -0.118, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyToasterFilter(to image: CIImage) -> CIImage? {
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = image
        colorMatrix.rVector = CIVector(x: 1.2, y: 0.2, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.0, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 0.8, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.157, y: 0.078, z: 0, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyHudsonFilter(to image: CIImage) -> CIImage? {
        guard let saturationFilter = applySaturation(to: image, saturation: 1.1) else { return nil }
            
            let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = saturationFilter
        colorMatrix.rVector = CIVector(x: 1.0, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.0, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.2, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.039, y: 0.039, z: -0.039, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyPerpetuaFilter(to image: CIImage) -> CIImage? {
        guard let saturationFilter = applySaturation(to: image, saturation: 1.5) else { return nil }
            
            let colorMatrix = CIFilter.colorMatrix()
        
        colorMatrix.inputImage = saturationFilter
        colorMatrix.rVector = CIVector(x: 1.0, y: 0.1, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1.1, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1.0, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.059, y: 0.078, z: 0.039, w: 0)
        return colorMatrix.outputImage
    }
    
    private func applyMayfairFilter(to image: CIImage) -> CIImage? {
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = image
        colorMatrix.rVector = CIVector(x: 1.1, y: 0.2, z: 0.1, w: 0)
        colorMatrix.gVector = CIVector(x: 0.1, y: 1.0, z: 0.1, w: 0)
        colorMatrix.bVector = CIVector(x: 0.1, y: 0.1, z: 0.9, w: 0)
        colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        colorMatrix.biasVector = CIVector(x: 0.078, y: 0.059, z: 0.039, w: 0)
        return colorMatrix.outputImage
    }
    
    // MARK: - Helper Functions
    
    private func applySaturation(to image: CIImage, saturation: Float) -> CIImage? {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.saturation = saturation
        return filter.outputImage
    }
    
    private func applyGrayscale(to image: CIImage) -> CIImage? {
        let filter = CIFilter.colorMonochrome()
        filter.inputImage = image
        filter.color = CIColor.gray
        filter.intensity = 1.0
        return filter.outputImage
    }
    
    private func applyVignette(to image: CIImage) -> CIImage? {
        let filter = CIFilter.vignette()
        filter.inputImage = image
        filter.intensity = 0.7
        filter.radius = 1.0
        return filter.outputImage
    }
    
    private func resizeImage(_ image: UIImage, maxSize: Int) -> UIImage {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var targetSize: CGSize
        if size.width > size.height {
            targetSize = CGSize(width: CGFloat(maxSize), height: CGFloat(maxSize) / aspectRatio)
        } else {
            targetSize = CGSize(width: CGFloat(maxSize) * aspectRatio, height: CGFloat(maxSize))
        }
        
        if size.width <= CGFloat(maxSize) && size.height <= CGFloat(maxSize) {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}

// Usage example:
/*
let processor = ImageFilterProcessor()
let filteredImage = await processor.applyFilters(
    to: originalImage,
    filters: [Filter(type: .vintage)],
    maxSize: 1024
)
*/
