//
//  Day18.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-18.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day18: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day18",
                abstract: "Solve day 18 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let droplets: [Point3D] = try readLines().compactMap(Point3D.init)
            
            printTitle("Part 1", level: .title1)
            let surfaceArea = part1(droplets: droplets)
            print(
                "What is the surface area of your scanned lava droplet?",
                surfaceArea,
                terminator: "\n\n"
            )
            
            printTitle("Part 2", level: .title1)
            let exteriorSurfaceArea = part2(droplets: droplets)
            print(
                "What is the exterior surface area of your scanned lava droplet?",
                exteriorSurfaceArea
            )
        }
        
        func part1(droplets: [Point3D]) -> Int {
            let droplets = Set(droplets)
            let translations: [Translation3D] = [
                .positiveX,
                .negativeX,
                .positiveY,
                .negativeY,
                .positiveZ,
                .negativeZ,
            ]
            let surfaceArea = droplets.reduce(into: 0, { result, droplet in
                let adjacentDroplets = Set(translations.map({ droplet.applying($0) })).intersection(droplets)
                result += 6 - adjacentDroplets.count
            })
            
            return surfaceArea
        }
        
        func part2(droplets: [Point3D]) -> Int {
            let droplets = Set(droplets)
            var filledPoints = Set<Point3D>()
            let translations: [Translation3D] = [
                .positiveX,
                .negativeX,
                .positiveY,
                .negativeY,
                .positiveZ,
                .negativeZ,
            ]
            var xCoordinates = Set<Int>()
            var yCoordinates = Set<Int>()
            var zCoordinates = Set<Int>()
            
            for point in droplets {
                xCoordinates.insert(point.x)
                yCoordinates.insert(point.y)
                zCoordinates.insert(point.z)
            }
            let rangeOfX = (xCoordinates.min()! - 1) ... (xCoordinates.max()! + 1)
            let rangeOfY = (yCoordinates.min()! - 1) ... (yCoordinates.max()! + 1)
            let rangeOfZ = (zCoordinates.min()! - 1) ... (zCoordinates.max()! + 1)
            
            func canBeFilled(_ point: Point3D) -> Bool {
                guard rangeOfX.contains(point.x), rangeOfY.contains(point.y), rangeOfZ.contains(point.z) else {
                    return false
                }
                
                if droplets.contains(point) {
                    return false
                }
                
                return !filledPoints.contains(point)
            }
            
            func floodFill(_ point: Point3D) {
                guard canBeFilled(point) else {
                    return
                }
                
                filledPoints.insert(point)
                
                for translation in translations {
                    floodFill(point.applying(translation))
                }
            }
            
            let startingPoint = Point3D(x: rangeOfX.lowerBound, y: rangeOfY.lowerBound, z: rangeOfZ.lowerBound)
            floodFill(startingPoint)
            
            let exteriorSafeArea = droplets.reduce(into: 0, { result, droplet in
                let numberOfSidesReachableBySteam = translations.count(where: { translation in
                    filledPoints.contains(droplet.applying(translation))
                })
                
                result += numberOfSidesReachableBySteam
            })
            
            return exteriorSafeArea
        }
    }
}

struct Point3D: Hashable {
    var x: Int
    var y: Int
    var z: Int
    
    func applying(_ translation: Translation3D) -> Point3D {
        var copy = self
        copy.apply(translation)
        return copy
    }
    
    mutating func apply(_ translation: Translation3D) {
        x += translation.deltaX
        y += translation.deltaY
        z += translation.deltaZ
    }
}

fileprivate extension Point3D {
    init?(rawValue: String) {
        let coordinates = rawValue.components(separatedBy: ",").compactMap(Int.init)
        guard coordinates.count == 3 else {
            return nil
        }
        
        self.x = coordinates[0]
        self.y = coordinates[1]
        self.z = coordinates[2]
    }
}

struct Translation3D {
    var deltaX: Int
    var deltaY: Int
    var deltaZ: Int
    
    static let positiveX = Self(deltaX: 1, deltaY: 0, deltaZ: 0)
    static let negativeX = Self(deltaX: -1, deltaY: 0, deltaZ: 0)
    static let positiveY = Self(deltaX: 0, deltaY: 1, deltaZ: 0)
    static let negativeY = Self(deltaX: 0, deltaY: -1, deltaZ: 0)
    static let positiveZ = Self(deltaX: 0, deltaY: 0, deltaZ: 1)
    static let negativeZ = Self(deltaX: 0, deltaY: 0, deltaZ: -1)
}
