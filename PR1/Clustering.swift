//
//  Main.swift
//  PR1
//
//  Created by Maximilian Stumpf on 14.12.17.
//  Copyright © 2017 Maximilian Stumpf. All rights reserved.
//

import UIKit

// This extension returns the color of a specific pixel in an UIImage
extension UIImage {
    
    func getPixelColor (x: Int, y: Int) -> UIColor? {
        
        if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
            return nil
        }
        
        let provider = self.cgImage?.dataProvider
        let providerData = provider.unsafelyUnwrapped.data
        let data = CFDataGetBytePtr(providerData)
        
        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents
        
        let r = CGFloat(data![pixelData]) / 255.0
        let g = CGFloat(data![pixelData + 1]) / 255.0
        let b = CGFloat(data![pixelData + 2]) / 255.0
        let a = CGFloat(data![pixelData + 3]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}

// This extension returns the values of the red, green, blue and alpha components of a color
extension UIColor {
    
    func getRGBAComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        
        var (red, green, blue, alpha) = (CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0))
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red, green, blue, alpha)
        } else {
            return nil
        }
    }
}

class Clustering {
    private let image: UIImage
    private let imageHeight: Int
    private let imageWidth: Int
    private let clusteringMethod: Int //1 = K-Means, 2 = DBSCAN
    
    private var euclidMetric = true
    private var k: Int?
    private var e: Float?
    private var minpts: Int?
    private var clusters: [[[Float]]]!
    private var pixelArray = [[Float]]()
    private var meanColors = [UIColor]()
    private var clusteredImage = UIImage()
    
    
    init(image: UIImage, k: Int) {
        self.image = image
        self.imageHeight = Int(image.size.height)
        self.imageWidth = Int(image.size.width)
        self.k = k
        self.clusteringMethod = 1
    }
    
    init(image: UIImage, e: Float, minpts: Int, metric: Bool) {
        self.image = image
        self.imageHeight = Int(image.size.height)
        self.imageWidth = Int(image.size.width)
        self.e = e
        self.minpts = minpts
        self.euclidMetric = metric
        self.clusteringMethod = 2
    }
    
    public func returnClusteredImage() -> UIImage {
        start()
        return clusteredImage
    }
    
    // This method prepares the image data for the application-neutral clustering algorithms
    private func start() {
        for y in 0...imageHeight-1 {
            for x in 0...imageWidth-1 {
                let color = image.getPixelColor(x: x, y: y)!
                let pixel = [Float((color.getRGBAComponents()?.red)!), Float((color.getRGBAComponents()?.green)!), Float((color.getRGBAComponents()?.blue)!)]
                pixelArray.append(pixel)
            }
        }
        if clusteringMethod == 1 {
            let kmeans = Kmeans.init(vecs: pixelArray, kVal: k!)
            clusters = kmeans.returnClusters()
        } else {
            let dbscan = DBSCAN.init(vecs: pixelArray, eVal: e!, mpVal: minpts!, met: euclidMetric)
            clusters = dbscan.returnClusters()
        }
        for cluster in clusters {
            meanColors.append(calculateMeanColor(pixels: cluster))
        }
        createClusteredImage()
    }
    
    // This method calculates and returns the mean color of a given set of pixels
    private func calculateMeanColor(pixels: [[Float]]) -> UIColor {
        var (redSum, greenSum, blueSum) = (CGFloat(0), CGFloat(0), CGFloat(0))
        for i in 0...pixels.count-1 {
            redSum += CGFloat(pixels[i][0])
            greenSum += CGFloat(pixels[i][1])
            blueSum += CGFloat(pixels[i][2])
        }
        let size = CGFloat(pixels.count)
        let (red, green, blue) = (redSum/size, greenSum/size, blueSum/size)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // This method basically brings the pixels in their original order and paints them in the color associated with their cluster, to finally set the resulting clustered image
    private func createClusteredImage() {
        var clusterPixelArray = [PixelData]()
        
        for pixel in 0...pixelArray.count-1 {
            for i in 0...clusters.count-1 {
                for item in 0...clusters[i].count-1 {
                    if pixelArray[pixel] == clusters[i][item] {
                        var newPixel = PixelData()
                        newPixel.a = 255
                        newPixel.r = UInt8((meanColors[i].getRGBAComponents()?.red)!*255.0)
                        newPixel.g = UInt8((meanColors[i].getRGBAComponents()?.green)!*255.0)
                        newPixel.b = UInt8((meanColors[i].getRGBAComponents()?.blue)!*255.0)
                        clusterPixelArray.append(newPixel)
                        break
                    }
                }
                if clusterPixelArray.count == pixel+1 {
                    break
                }
            }
        }
        clusteredImage = imageFromBitmap(pixels: clusterPixelArray, width: imageWidth, height: imageHeight)!
    }
    
    private struct PixelData {
        var a: UInt8 = 0
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
    }
    
    // This method produces the finished UIImage from the pixel array in createClusteredImage()
    private func imageFromBitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        let pixelDataSize = MemoryLayout<PixelData>.size
        let data: Data = pixels.withUnsafeBufferPointer {
            return Data(buffer: $0)
        }
        
        let cfdata = NSData(data: data) as CFData
        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
        if provider == nil {
            print("CGDataProvider is not supposed to be nil")
            return nil
        }
        let cgimage: CGImage! = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * pixelDataSize,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        if cgimage == nil {
            print("CGImage is not supposed to be nil")
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
}
