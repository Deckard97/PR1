//
//  Kmeans.swift
//  PR1
//
//  Created by Maximilian Stumpf on 12.12.17.
//  Copyright © 2017 Maximilian Stumpf. All rights reserved.
//

import Foundation

class Kmeans {
    private let vectors : [[Float]]
    private let k : Int
    private var clusters = [[[Float]]]()
    private var means = [[Float]]() // Saves the current means
    private var kmeansRunning = true // Indicates when the algorithm has finished
    
    init(vecs: [[Float]], kVal: Int) {
        self.vectors = vecs
        self.k = kVal
    }
    
    public func returnClusters() -> [[[Float]]] {
        initializeKmeans()
        return clusters
    }
    
    // This method creates k random starting means
    private func initializeKmeans() {
        for _ in 1...k {
            let rnd = Int(arc4random_uniform(UInt32(vectors.count)))
            let mean = vectors[rnd]
            means.append(mean)
            clusters.append([[Float]]())
        }
        startKmeans()
    }
    
    // This method contains the optimization loop and is terminated once the means don't change any further
    private func startKmeans() {
        while kmeansRunning {
            var checkpointFinish = 0
            for i in 0...clusters.count-1 {
                clusters[i].removeAll()
            }
            assignVectorsToMeans()
            for j in 0...means.count-1 {
                let newMean = calculateNewMean(index: j)
                if newMean == means[j] {
                    checkpointFinish += 1
                } else {
                    means[j] = newMean
                }
            }
            if checkpointFinish == k {
                kmeansRunning = false
            }
        }
    }
    
    // This Method calculates and returns the new mean value of every feature of every vector in a cluster
    private func calculateNewMean(index: Int) -> [Float] {
        var meanCalc = [Float]()
        for feature in 0...means[index].count-1 {
            var featureSum : Float = 0
            for vector in clusters[index] {
                featureSum += vector[feature]
            }
            meanCalc.append(featureSum/Float(clusters[index].count))
        }
        return meanCalc
    }
    
    private func assignVectorsToMeans() {
        for vector in vectors {
            findNearestMean(vector: vector)
        }
    }
    
    // This method finds the nearest mean for a given vector and puts it in the corresponding container
    private func findNearestMean(vector: [Float]) {
        var minDist : Float = -1
        var meanIndex = -1
        for i in 0...means.count-1 {
            let newDist = calculateDistance(mean: means[i], vector: vector)
            if newDist < minDist || minDist<0 {
                minDist = newDist
                meanIndex = i
            }
        }
        clusters[meanIndex].append(vector)
    }
    
    // Calculates and returns the euclidean distance between two vectors
    private func calculateDistance(mean: [Float], vector: [Float]) -> Float {
        var distanceSquared : Float = 0
        for i in 0...vector.count-1 {
            distanceSquared = distanceSquared + pow(Float(mean[i]-vector[i]), 2)
        }
        return distanceSquared.squareRoot()
    }
}
