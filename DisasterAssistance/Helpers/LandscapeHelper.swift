//
//  LandscapeHelper.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 27.04.2024.
//

import Foundation

enum LandscapeType: String {
    case city = "Город"
    case forest = "Лес"
    case mountain = "Горы"
    case all = "Всп"
}

struct Landscape {
    let type: LandscapeType
    let area: [Location]
//    let x1y1: Location
//    let x1y2: Location
//    let x2y1: Location
//    let x2y2: Location
}

final class LandscapeHelper {
    let landscapesCoordinates: [Landscape]
    
    init() {
        landscapesCoordinates = [
            Landscape(
                type: .forest,
                area: [Location(latitude: 56.429065063979934, longitude: 32.73421006967511),
                       Location(latitude: 56.6071026880465, longitude: 32.72528367853669),
                       Location(latitude: 56.46625683798548, longitude: 32.947756811524975),
                       Location(latitude: 56.56437425275999, longitude: 32.94501022963623)]
            ),
            Landscape(
                type: .city,
                area: [Location(latitude: 55.58080763362406, longitude: 37.85791201590754),
                       Location(latitude: 55.896239413767574, longitude: 37.81808657852075),
                       Location(latitude: 55.89777937343483, longitude: 37.35391423932297),
                       Location(latitude: 55.608742459428285, longitude: 37.381380058210404)]
            ),
            Landscape(
                type: .mountain,
                area: [Location(latitude: 52.31554930774885, longitude: 56.10044848351916),
                       Location(latitude: 52.10011269419161, longitude: 59.088729578472915),
                       Location(latitude: 65.59957848340972, longitude: 58.4734952353942),
                       Location(latitude: 65.49042419766147, longitude: 62.99986218804475)]
            )
        ]
    }
    
    func isCoordinateInLandscap(_ type: LandscapeType, coordinate: Location) -> Bool {
        if type == .all {
            return true
        }
        for land in landscapesCoordinates {
            if land.type == type {
                return LocationInsidePolygon(location: coordinate, polygon: land.area)
            }
//            return false
            
        }
        return false
    }
}

extension LandscapeHelper {
    func LocationInsidePolygon(location: Location, polygon: [Location]) -> Bool {
        var intersectCount = 0
        
        // Создаем луч, который начинается от нашей точки и направлен вправо на бесконечность
        let rayEnd = Location(latitude: Double.infinity, longitude: location.longitude)
        
        // Проходимся по всем ребрам многоугольника
        for i in 0..<polygon.count {
            let p1 = polygon[i]
            let p2 = polygon[(i + 1) % polygon.count]
            
            // Проверяем, есть ли пересечение луча с ребром
            if rayIntersectsEdge(location: location, rayEnd: rayEnd, edgeStart: p1, edgeEnd: p2) {
                intersectCount += 1
            }
        }
        
        // Если количество пересечений нечетное, то точка внутри многоугольника
        return intersectCount % 2 == 1
    }

    func rayIntersectsEdge(location: Location, rayEnd: Location, edgeStart: Location, edgeEnd: Location) -> Bool {
        // Проверяем, лежат ли концы отрезка выше и ниже точки
        if (edgeStart.longitude <= location.longitude && edgeEnd.longitude >= location.longitude) ||
           (edgeStart.longitude >= location.longitude && edgeEnd.longitude <= location.longitude) {
            
            // Если оба условия выполняются, проверяем пересечение луча с ребром
            let intersectionlatitude = (edgeEnd.latitude - edgeStart.latitude) * (location.longitude - edgeStart.longitude) / (edgeEnd.longitude - edgeStart.longitude) + edgeStart.latitude
            
            // Проверяем, лежит ли точка пересечения правее нашей точки
            if intersectionlatitude >= location.latitude {
                return true
            }
        }
        
        return false
    }
}
