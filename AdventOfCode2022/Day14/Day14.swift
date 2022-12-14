//
//  Day14.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-13.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

extension Commands {
    struct Day14: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day14",
                abstract: "Solve day 14 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let paths: [Path] = try readLines().compactMap({ line in
                let components = line.components(separatedBy: " -> ")
                return components.compactMap({ point in
                    let coordinates = point.components(separatedBy: ",").compactMap(Int.init)
                    
                    guard coordinates.count == 2 else {
                        return nil
                    }
                    
                    return Point2D(x: coordinates[0], y: coordinates[1])
                })
            })
            
            let numberOfUnitsOfSand = part1(paths: paths)
            printTitle("Part 1", level: .title1)
            print(
                "How many units of sand come to rest before sand starts flowing into the abyss below?",
                numberOfUnitsOfSand,
                terminator: "\n\n"
            )
        }
        
        func part1(paths: [Path]) -> Int {
            let sourceOfSand = Point2D(x: 500, y: 0)
            var itemsByPoint = itemsByPoint(paths: paths)
            let lowestY = itemsByPoint.keys.min(by: { $0.y > $1.y })!.y
            let down = Translation2D(deltaX: 0, deltaY: 1)
            let downLeft = Translation2D(deltaX: -1, deltaY: 1)
            let downRight = Translation2D(deltaX: 1, deltaY: 1)
            
            var sandIsFallingInTheAbyss = false
            pouringGrains: repeat {
                var hasComeToRest = false
                var currentPosition = sourceOfSand
                while !hasComeToRest {
                    sandIsFallingInTheAbyss = currentPosition.y >= lowestY
                    
                    if sandIsFallingInTheAbyss {
                        break pouringGrains
                    }
                    
                    switch itemsByPoint[currentPosition.applying(down), default: .air] {
                    case .air:
                        currentPosition.apply(down)
                        continue
                        
                    case .rock, .sand:
                        break
                    }
                    
                    switch itemsByPoint[currentPosition.applying(downLeft), default: .air] {
                    case .air:
                        currentPosition.apply(downLeft)
                        continue
                        
                    case .rock, .sand:
                        break
                    }
                    
                    switch itemsByPoint[currentPosition.applying(downRight), default: .air] {
                    case .air:
                        currentPosition.apply(downRight)
                        continue
                        
                    case .rock, .sand:
                        break
                    }
                    
                    hasComeToRest = true
                }
                
                itemsByPoint[currentPosition] = .sand
            }
            while !sandIsFallingInTheAbyss
            
            return itemsByPoint.values.count(of: .sand)
        }
        
        private func itemsByPoint(paths: [Path]) -> [Point2D: Item]  {
            var itemsByPoint = [Point2D: Item]()
            for path in paths {
                for window in path.windows(ofCount: 2) {
                    let minX = min(window.first!.x, window.last!.x)
                    let maxX = max(window.first!.x, window.last!.x)
                    let minY = min(window.first!.y, window.last!.y)
                    let maxY = max(window.first!.y, window.last!.y)
                    
                    let rangeOfX = minX ... maxX
                    let rangeOfY = minY ... maxY
                    
                    for (x, y) in product(rangeOfX, rangeOfY) {
                        itemsByPoint[.init(x: x, y: y)] = .rock
                    }
                }
            }
            return itemsByPoint
        }
        
        typealias Path = [Point2D]
        
        enum Item: Character {
            case sand = "o"
            case air = "."
            case rock = "#"
        }
    }
}
