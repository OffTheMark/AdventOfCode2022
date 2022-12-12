//
//  Day12.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-12.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

extension Commands {
    struct Day12: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day12",
                abstract: "Solve day 12 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let grid = Grid(rawValue: try readFile())!
            
            let fewestStepsToReachLocationWithBestSignal = part1(grid: grid)
            printTitle("Part 1", level: .title1)
            print(
                "What is the fewest steps required to move from your current position to the location that should get the best signal?",
                fewestStepsToReachLocationWithBestSignal,
                terminator: "\n\n"
            )
        }
        
        func part1(grid: Grid) -> Int {
            var distancesByPoint = [grid.startingPoint: 0]
            var frontier: Deque = [grid.startingPoint]
            
            while let point = frontier.popFirst() {
                let distance = distancesByPoint[point, default: 0]
                
                for neighbor in point.neighbors {
                    guard grid.contains(neighbor) else {
                        continue
                    }
                    
                    guard !distancesByPoint.keys.contains(neighbor) ||
                            distancesByPoint[neighbor, default: 0] > distance + 1 else {
                        continue
                    }
                    
                    let elevationDifference = grid.elevationsByPoint[neighbor, default: 0]
                        - grid.elevationsByPoint[point, default: 0]
                    guard elevationDifference <= 1 else {
                        continue
                    }
                    
                    distancesByPoint[neighbor] = distance + 1
                    frontier.append(neighbor)
                }
            }
            
            return distancesByPoint[grid.target, default: 0]
        }
        
        struct Grid {
            let startingPoint: Point2D
            let target: Point2D
            let elevationsByPoint: [Point2D: Int]
            
            func contains(_ point: Point2D) -> Bool {
                elevationsByPoint[point] != nil
            }
            
            init?(rawValue: String) {
                var startingPoint: Point2D?
                var target: Point2D?
                var elevationsByPoint = [Point2D: Int]()
                let elevationByCharacter: [Character: Int] = zip("abcdefghijklmnopqrstuvwxyz", 0...)
                    .reduce(into: [:], { result, pair in
                        let (character, elevation) = pair
                        result[character] = elevation
                    })
                
                for (y, line) in rawValue.components(separatedBy: .newlines).enumerated() {
                    for (x, character) in line.enumerated() {
                        let point = Point2D(x: x, y: y)
                        
                        if character == "S" {
                            startingPoint = point
                            elevationsByPoint[point] = elevationByCharacter["a", default: 0]
                        }
                        else if character == "E" {
                            target = point
                            elevationsByPoint[point] = elevationByCharacter["z", default: 0]
                        }
                        else {
                            elevationsByPoint[point] = elevationByCharacter[character]
                        }
                    }
                }
                
                guard let startingPoint, let target else {
                    return nil
                }
                
                self.startingPoint = startingPoint
                self.target = target
                self.elevationsByPoint = elevationsByPoint
            }
        }

        
        struct Path {
            let destination: Point2D
            let distance: Int
        }
    }
}

extension Point2D {
    var neighbors: [Point2D] {
        [
            Point2D(x: x, y: y - 1),
            Point2D(x: x + 1, y: y),
            Point2D(x: x, y: y + 1),
            Point2D(x: x - 1, y: y),
        ]
    }
}
