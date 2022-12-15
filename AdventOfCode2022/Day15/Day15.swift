//
//  Day15.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-15.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

extension Commands {
    struct Day15: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day15",
                abstract: "Solve day 15 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        @Argument(help: "Target y")
        var targetY: Int
        
        func run() throws {
            let pairs: [(sensor: Point2D, beacon: Point2D)] = try readLines().compactMap(parse)
            
            printTitle("Part 1", level: .title1)
            let numberOfPositionsThatCannotContainABeacon = part1(pairs: pairs, targetY: targetY)
            print(
                "In the row where y=\(targetY), how many positions cannot contain a beacon?",
                numberOfPositionsThatCannotContainABeacon,
                terminator: "\n\n"
            )
        }
        
        private func parse(line: String) -> (sensor: Point2D, beacon: Point2D)? {
            let components = line.components(separatedBy: ": ")
            guard components.count == 2 else {
                return nil
            }
            
            guard let sensor = parseSensor(components[0]) else {
                return nil
            }
            
            guard let beacon = parseBeacon(components[1]) else {
                return nil
            }
            
            return (sensor, beacon)
        }
        
        private func parseSensor(_ rawValue: String) -> Point2D? {
            let coordinates = rawValue.removingPrefix("Sensor at ")
                .components(separatedBy: ", ")
                .compactMap({
                    Int($0.removingPrefix("x=").removingPrefix("y="))
                })
            
            guard coordinates.count == 2 else {
                return nil
            }
            
            return Point2D(x: coordinates[0], y: coordinates[1])
        }
        
        private func parseBeacon(_ rawValue: String) -> Point2D? {
            let coordinates = rawValue.removingPrefix("closest beacon is at ")
                .components(separatedBy: ", ")
                .compactMap({
                    Int($0.removingPrefix("x=").removingPrefix("y="))
                })
            
            guard coordinates.count == 2 else {
                return nil
            }
            
            return Point2D(x: coordinates[0], y: coordinates[1])
        }
        
        func part1(pairs: [(sensor: Point2D, beacon: Point2D)], targetY: Int) -> Int {
            let occupiedPoints: Set<Point2D> = pairs.reduce(into: [], { result, pair in
                result.insert(pair.sensor)
                result.insert(pair.beacon)
            })
            var pointsWhereNoBeaconCanBeAtTargetY = Set<Point2D>()
            
            for (sensor, beacon) in pairs {
                let distanceToBeacon = sensor.manhattanDistance(to: beacon)
                let deltaYToTargetY = targetY - sensor.y
                
                guard abs(deltaYToTargetY) <= distanceToBeacon else {
                    continue
                }
                
                let absoluteDeltaXAtTargetX = distanceToBeacon - abs(deltaYToTargetY)
                
                for deltaX in -absoluteDeltaXAtTargetX ... absoluteDeltaXAtTargetX {
                    let candidate = Point2D(x: sensor.x + deltaX, y: targetY)
                    
                    guard !occupiedPoints.contains(candidate) else {
                        continue
                    }
                    
                    pointsWhereNoBeaconCanBeAtTargetY.insert(candidate)
                }
            }
            
            return pointsWhereNoBeaconCanBeAtTargetY.count(where: { $0.y == targetY })
        }
    }
}

extension Point2D {
    func manhattanDistance(to other: Point2D) -> Int {
        abs(other.x - x) + abs(other.y - y)
    }
}
