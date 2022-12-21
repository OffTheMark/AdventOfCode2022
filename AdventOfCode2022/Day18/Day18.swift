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
            let coordinateRangesPerPlane: [RangeKey: ClosedRange<Int>] = droplets.reduce(into: [:], { result, droplet in
                let xRangeKey = droplet.xRangeKey
                if let rangeOfX = result[xRangeKey] {
                    let newRange = min(rangeOfX.lowerBound, droplet.x) ... max(rangeOfX.upperBound, droplet.x)
                    result[xRangeKey] = newRange
                }
                else {
                    result[xRangeKey] = droplet.x ... droplet.x
                }
                
                let yRangeKey = droplet.yRangeKey
                if let rangeOfY = result[yRangeKey] {
                    let newRange = min(rangeOfY.lowerBound, droplet.y) ... max(rangeOfY.upperBound, droplet.y)
                    result[yRangeKey] = newRange
                }
                else {
                    result[yRangeKey] = droplet.y ... droplet.y
                }
                
                let zRangeKey = droplet.zRangeKey
                if let rangeOfZ = result[zRangeKey] {
                    let newRange = min(rangeOfZ.lowerBound, droplet.z) ... max(rangeOfZ.upperBound, droplet.z)
                    result[zRangeKey] = newRange
                }
                else {
                    result[zRangeKey] = droplet.z ... droplet.z
                }
            })
            
            let exteriorSurfaceArea = droplets.reduce(into: 0, { result, droplet in
                let rangeOfX = coordinateRangesPerPlane[droplet.xRangeKey]!
                let rangeOfY = coordinateRangesPerPlane[droplet.yRangeKey]!
                let rangeOfZ = coordinateRangesPerPlane[droplet.zRangeKey]!
                
                if droplet.x == rangeOfX.lowerBound {
                    result += 1
                }
                if droplet.x == rangeOfX.upperBound {
                    result += 1
                }
                if droplet.y == rangeOfY.lowerBound {
                    result += 1
                }
                if droplet.y == rangeOfY.upperBound {
                    result += 1
                }
                if droplet.z == rangeOfZ.lowerBound {
                    result += 1
                }
                if droplet.z == rangeOfZ.upperBound {
                    result += 1
                }
            })
            
            return exteriorSurfaceArea
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
    
    var xRangeKey: RangeKey { .x(y: y, z: z) }

    var yRangeKey: RangeKey { .y(x: x, z: z) }
    
    var zRangeKey: RangeKey { .z(x: x, y: y) }
}

fileprivate enum RangeKey: Hashable {
    case x(y: Int, z: Int)
    case y(x: Int, z: Int)
    case z(x: Int, y: Int)
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
