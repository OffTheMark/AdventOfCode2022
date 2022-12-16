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
        
        @Argument(help: "Coordinate bound")
        var coordinateBound: Int
        
        func run() throws {
            let pairs: [(sensor: Point2D, beacon: Point2D)] = try readLines().compactMap(parse)
            
            printTitle("Part 1", level: .title1)
            let numberOfPositionsThatCannotContainABeacon = part1(pairs: pairs, targetY: targetY)
            print(
                "In the row where y=\(targetY), how many positions cannot contain a beacon?",
                numberOfPositionsThatCannotContainABeacon,
                terminator: "\n\n"
            )
            
            printTitle("Part 2", level: .title1)
            let tuningFrequency = part2(pairs: pairs, coordinateBound: coordinateBound)
            print(
                "Find the only possible position for the distress beacon. What is its tuning frequency?",
                tuningFrequency
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
            let occupiedPointsAtTargetY: Set<Point2D> = pairs.reduce(into: [], { result, pair in
                if pair.sensor.y == targetY {
                    result.insert(pair.sensor)
                }
                if pair.beacon.y == targetY {
                    result.insert(pair.beacon)
                }
            })
            var pointsWhereNoBeaconCanBeAtTargetY = Set<Point2D>()
            
            for (sensor, beacon) in pairs {
                let distanceToBeacon = sensor.manhattanDistance(to: beacon)
                let deltaYToTargetY = targetY - sensor.y
                
                guard abs(deltaYToTargetY) <= distanceToBeacon else {
                    continue
                }
                
                let absoluteDeltaXAtTargetY = distanceToBeacon - abs(deltaYToTargetY)
                let deltaXRange = -absoluteDeltaXAtTargetY ... absoluteDeltaXAtTargetY
                let vacantPointsAtTargetY: Set<Point2D> = Set(
                    deltaXRange.map({ deltaX in
                        Point2D(x: sensor.x + deltaX, y: targetY)
                    })
                )
                .subtracting(occupiedPointsAtTargetY)
                
                pointsWhereNoBeaconCanBeAtTargetY.formUnion(vacantPointsAtTargetY)
            }
            
            return pointsWhereNoBeaconCanBeAtTargetY.count
        }
        
        // https://www.reddit.com/r/adventofcode/comments/zmcn64/comment/j0b90nr/
        func part2(pairs: [(sensor: Point2D, beacon: Point2D)], coordinateBound: Int) -> Int {
            let distancesBySensor: [Point2D: Int] = pairs.reduce(into: [:], { result, pair in
                result[pair.sensor] = pair.sensor.manhattanDistance(to: pair.beacon)
            })
            var aCoefficients = Set<Int>()
            var bCoefficients = Set<Int>()
            
            for (sensor, distance) in distancesBySensor {
                aCoefficients.insert(sensor.y - sensor.x + distance + 1)
                aCoefficients.insert(sensor.y - sensor.x - distance - 1)
                bCoefficients.insert(sensor.y + sensor.x + distance + 1)
                bCoefficients.insert(sensor.y + sensor.x - distance - 1)
            }
            
            let validCoordinateRange = 0 ... coordinateBound
            
            let point = product(aCoefficients, bCoefficients).lazy
                .map({ pair in
                    let (a, b) = pair
                    return Point2D(x: (b - a) / 2, y: (a + b) / 2)
                })
                .first(where: { candidate in
                    guard validCoordinateRange.contains(candidate.x), validCoordinateRange.contains(candidate.y) else {
                        return false
                    }
                    
                    return distancesBySensor.allSatisfy({ pair in
                        let (sensor, distance) = pair
                        return candidate.manhattanDistance(to: sensor) > distance
                    })
                })!
            
            return point.x * 4_000_000 + point.y
        }
    }
}

extension Point2D {
    func manhattanDistance(to other: Point2D) -> Int {
        abs(other.x - x) + abs(other.y - y)
    }
}
