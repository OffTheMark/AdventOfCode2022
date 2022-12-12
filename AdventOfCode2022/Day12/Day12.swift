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
            
            let fewestStepsFromAnySquareToLocationWithBestSignal = part2(grid: grid)
            printTitle("Part 2", level: .title1)
            print(
                "What is the fewest steps required to move starting from any square with elevation a to the location that should get the best signal?",
                fewestStepsFromAnySquareToLocationWithBestSignal
            )
        }
        
        func part1(grid: Grid) -> Int {
            let distanceByPoint = distancesGoingUp(from: grid.startingPoint, elevationsByPoint: grid.elevationsByPoint)
            return distanceByPoint[grid.target, default: 0]
        }
        
        func part2(grid: Grid) -> Int {
            let distancesByPoint = distancesGoingDown(from: grid.target, elevationsByPoint: grid.elevationsByPoint)
            
            return distancesByPoint
                .filter({ grid.elevationsByPoint[$0.key] == 0 })
                .min(by: { distancesByPoint[$0.key, default: 0] < distancesByPoint[$1.key, default: 0] })!
                .value
        }
        
        private func distancesGoingUp(
            from start: Point2D,
            elevationsByPoint: [Point2D: Int]
        ) -> [Point2D: Int] {
            // Map all the shortest distances from the start to any point while going up using breadth-first search
            var distancesByPoint = [start: 0]
            var queue: Deque = [start]
            
            while let point = queue.popFirst() {
                let distance = distancesByPoint[point, default: 0]
                
                let neighbors = point.neighbors.filter({ neighbor in
                    guard elevationsByPoint.keys.contains(neighbor) else {
                        return false
                    }
                    
                    if distancesByPoint.keys.contains(neighbor),
                       distancesByPoint[neighbor, default: 0] <= distance + 1 {
                        return false
                    }
                    
                    let elevationDifference = elevationsByPoint[neighbor, default: 0]
                        - elevationsByPoint[point, default: 0]
                    return elevationDifference <= 1
                })
                
                for neighbor in neighbors {
                    distancesByPoint[neighbor] = distance + 1
                    queue.append(neighbor)
                }
            }
            
            return distancesByPoint
        }
        
        private func distancesGoingDown(
            from end: Point2D,
            elevationsByPoint: [Point2D: Int]
        ) -> [Point2D: Int] {
            // Map all the shortest distances from the end to any point while going down using breadth-first search
            var distancesByPoint = [end: 0]
            var queue: Deque = [end]
            
            while let point = queue.popFirst() {
                let distance = distancesByPoint[point, default: 0]
                
                let neighbors = point.neighbors.filter({ neighbor in
                    guard elevationsByPoint.keys.contains(neighbor) else {
                        return false
                    }
                    
                    if distancesByPoint.keys.contains(neighbor),
                        distancesByPoint[neighbor, default: 0] <= distance + 1 {
                        return false
                    }
                    
                    let elevationDifference = elevationsByPoint[point, default: 0]
                        - elevationsByPoint[neighbor, default: 0]
                    return elevationDifference <= 1
                })
                
                for neighbor in neighbors {
                    distancesByPoint[neighbor] = distance + 1
                    queue.append(neighbor)
                }
            }
            
            return distancesByPoint
        }
        
        private func shortestDistance(
            from start: Point2D,
            to end: Point2D,
            elevationsByPoint: [Point2D: Int]
        ) -> Int {
            var distancesByPoint = [start: 0]
            var queue: Deque = [start]
            
            while let point = queue.popFirst() {
                let distance = distancesByPoint[point, default: 0]
                
                for neighbor in point.neighbors {
                    guard elevationsByPoint.keys.contains(neighbor) else {
                        continue
                    }
                    
                    guard !distancesByPoint.keys.contains(neighbor) ||
                            distancesByPoint[neighbor, default: 0] > distance + 1 else {
                        continue
                    }
                    
                    let elevationDifference = elevationsByPoint[neighbor, default: 0]
                        - elevationsByPoint[point, default: 0]
                    guard elevationDifference <= 1 else {
                        continue
                    }
                    
                    distancesByPoint[neighbor] = distance + 1
                    queue.append(neighbor)
                }
            }
            
            return distancesByPoint[end, default: 0]
        }
        
        private func shortestDistanceFromAnyLowestPoint(
            to end: Point2D,
            elevationsByPoint: [Point2D: Int]
        ) -> Int? {
            var frontier: Deque<[Point2D]> = [[end]] {
                didSet {
                    frontier.sort(by: { $0.count < $1.count })
                }
            }
            var visited = Set<Point2D>()
            
            while let shortestPath = frontier.popFirst() {
                let last = shortestPath.last!
                
                if elevationsByPoint[last] == 0 {
                    return shortestPath.count - 1
                }
                
                visited.insert(last)
                
                let neighbors = last.neighbors.filter({ neighbor in
                    guard elevationsByPoint.keys.contains(neighbor) else {
                        return false
                    }
                    
                    guard !visited.contains(neighbor) else {
                        return false
                    }
                    
                    let elevationDifference = elevationsByPoint[last, default: 0] - elevationsByPoint[neighbor, default: 0]
                    return elevationDifference <= 1
                })
                
                for neighbor in neighbors {
                    let path = shortestPath + [neighbor]
                    frontier.append(path)
                }
            }
            
            return nil
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
