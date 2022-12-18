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
            let adjacentDropletsByDroplet: [Point3D: Set<Point3D>] = droplets.reduce(into: [:], { result, droplet in
                let adjacentDroplets = Set(translations.map({ droplet.applying($0) })).intersection(droplets)
                result[droplet] = adjacentDroplets
            })
            
            return adjacentDropletsByDroplet.values.reduce(into: 0, { result, adjacentDroplets in
                result += 6 - adjacentDroplets.count
            })
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
