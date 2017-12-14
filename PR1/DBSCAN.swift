//
//  DBSCAN.swift
//  PR1
//
//  Created by Maximilian Stumpf on 12.12.17.
//  Copyright © 2017 Maximilian Stumpf. All rights reserved.
//

import Foundation

class DBSCAN {
    private let vectors : [[Float]]
    private let e : Float!
    private let minpts : Int
    private let euclidMetric : Bool
    private var clusterIndexes: [Int]! // This array saves the associated cluster for each vector
    private var clusters = [[[Float]]]() //This 3 dimensional array contains the finished clusters
    private var clusterId = 1
    
    init(vecs: [[Float]], eVal: Float, mpVal: Int, met: Bool) {
        self.vectors = vecs
        self.e = eVal
        self.minpts = mpVal
        self.euclidMetric = met
    }
    
    public func returnClusters() -> [[[Float]]]{
        initialize()
        
        return clusters
    }
    
    private func initialize() {
        clusterIndexes = Array(repeating: -1, count: vectors.count)
        startClustering()
    }
    
    // The clustering algorithm is implemented according to Ester/Sander p.72
    private func startClustering() {
        clusters.append([[Float]]()) // This is cluster 0 (Noise)
        clusters.append([[Float]]()) // This is cluster 1 (The first real cluster)
        for i in 0...vectors.count-1 {
            if clusterIndexes[i] == -1 {
                if expandCluster(vector: vectors[i], location: i) {
                    clusterId += 1
                    clusters.append([[Float]]())
                }
            }
        }
        
        clusters.removeLast()
        
        for j in 0...vectors.count-1 {
            clusters[clusterIndexes[j]].append(vectors[j])
        }
    }
    
    private func expandCluster(vector: [Float], location: Int) -> Bool {
        var seeds = regionQuery(vector: seedContainer(vector: vector, location: location))
        if seeds.count < minpts {
            clusterIndexes[location] = 0
            return false
        }
        for item in seeds {
            clusterIndexes[item.location] = clusterId
        }
        seeds.removeFirst()
        while !seeds.isEmpty {
            let neighborhood = regionQuery(vector: seeds.first!)
            if neighborhood.count >= minpts {
                for vec in neighborhood {
                    if clusterIndexes[vec.location] < 1 {
                        if clusterIndexes[vec.location] == -1 {
                            seeds.append(vec)
                        }
                        clusterIndexes[vec.location] = clusterId
                    }
                }
            }
            seeds.removeFirst()
        }
        return true
    }
    
    // This struct is necessary to transport the associated location in the original container of every vector
    private struct seedContainer {
        let vector : [Float]
        let location : Int
    }
    
    // This method finds every valid vector within the specified distance and returns them in an array
    private func regionQuery(vector: seedContainer) -> [seedContainer] {
        var neighborhood = [seedContainer]()
        neighborhood.append(vector)
        for i in 0...vectors.count-1 {
            let distance = calculateDistance(vector1: vector.vector, vector2: vectors[i])
            if distance < e && vector.location != i {
                neighborhood.append(seedContainer(vector: vectors[i], location: i))
            }
        }
        return neighborhood
    }
    
    // This method calculates and returns the distance between two vectors, depending on the specified metric
    private func calculateDistance(vector1: [Float], vector2: [Float]) -> Float {
        if euclidMetric {
            var distanceSquared : Float = 0
            for i in 0...vector1.count-1 {
                distanceSquared = distanceSquared + pow(Float(vector1[i]-vector2[i]), 2)
            }
            return distanceSquared.squareRoot()
        } else {
            var distanceMax = (vector1[0]-vector2[0]).magnitude
            for j in 1...vector1.count-1 {
                let distanceTemp = (vector1[j]-vector2[j]).magnitude
                if distanceTemp > distanceMax {
                    distanceMax = distanceTemp
                }
            }
            return distanceMax
        }
    }
    
}
