//
//  JarvisHelper.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 03.05.2024.
//

import Foundation

final class JarvisHelper {
    func orientation(p: Location, q: Location, r: Location) -> Int {
        let val = (q.longitude - p.longitude) * (r.latitude - q.latitude) - (q.latitude - p.latitude) * (r.longitude - q.longitude)
        if val == 0 {
            return 0
        }
        return (val > 0) ? 1 : 2
    }

    func convexHull(points: [Location]) -> [Location] {
        let n = points.count
        if n < 3 {
            return []
        }
        
        var hull = [Location]()
        
        var l = 0
        for i in 1..<n {
            if points[i].longitude < points[l].longitude {
                l = i
            }
        }
        
        var p = l
        var q = 0
        
        repeat {
            hull.append(points[p])
            
            q = (p + 1) % n
            for i in 0..<n {
                if orientation(p: points[p], q: points[i], r: points[q]) == 2 {
                    q = i
                }
            }
            p = q
        } while p != l
        return hull
    }
}
