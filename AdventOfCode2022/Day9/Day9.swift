//
//  Day9.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-09.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

extension Commands {
    struct Day9: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day9",
                abstract: "Solve day 9 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let moves = try readLines().compactMap(Move.init)
            
            let numberOfPositionsVisitedByTailOfRopeWith2Knots = part1(moves: moves)
            printTitle("Part 1", level: .title1)
            print(
                "How many positions does the tail of the rope with two knots visit at least once?",
                numberOfPositionsVisitedByTailOfRopeWith2Knots,
                terminator: "\n\n"
            )
            
            let numberOfPositionsVisitedByTailOfRopeWith10Knots = part2(moves: moves)
            printTitle("Part 2", level: .title1)
            print(
                "How many positions does the tail of the rope with ten knots visit at least once?",
                numberOfPositionsVisitedByTailOfRopeWith10Knots
            )
        }
        
        func part1(moves: [Move]) -> Int {
            solve(numberOfKnots: 2, moves: moves)
        }
        
        func part2(moves: [Move]) -> Int {
            solve(numberOfKnots: 10, moves: moves)
        }
        
        func solve(numberOfKnots: Int, moves: [Move]) -> Int {
            assert(numberOfKnots >= 1, "numberOfKnots >= 1")
            var knotPositions: [Point2D] = .init(repeating: .zero, count: numberOfKnots)
            var visitedTailPositions: Set = [knotPositions[numberOfKnots - 1]]
            
            for move in moves {
                for _ in 0 ..< move.distance {
                    knotPositions[knotPositions.startIndex].apply(move.translation)
                    
                    for window in knotPositions.indices.windows(ofCount: 2) {
                        let currentKnot = window.last!
                        let previousKnot = window.first!
                        
                        if knotPositions[currentKnot].touches(knotPositions[previousKnot]) {
                            continue
                        }
                        
                        let translationToPreviousKnot = knotPositions[currentKnot].translation(
                            to: knotPositions[previousKnot]
                        )
                        knotPositions[currentKnot].apply(translationToPreviousKnot.normalized)
                    }
                    
                    visitedTailPositions.insert(knotPositions[numberOfKnots - 1])
                }
            }
            
            return visitedTailPositions.count
        }
        
        struct Move {
            let translation: Translation2D
            let distance: Int
            
            init?(rawValue: String) {
                let components = rawValue.components(separatedBy: " ")
                guard components.count == 2, let distance = Int(components[1]) else {
                    return nil
                }
                
                self.distance = distance
                
                switch components[0] {
                case "U":
                    self.translation = .up
                
                case "D":
                    self.translation = .down
                
                case "R":
                    self.translation = .right
                    
                case "L":
                    self.translation = .left
                    
                default:
                    return nil
                }
            }
        }
    }
}

fileprivate extension Point2D {
    func touches(_ other: Point2D) -> Bool {
        let translation = translation(to: other)
        
        return [translation.deltaX, translation.deltaY].allSatisfy({ abs($0) <= 1 })
    }
    
    func translation(to other: Point2D) -> Translation2D {
        Translation2D(deltaX: other.x - x, deltaY: other.y - y)
    }
}

fileprivate extension Translation2D {
    var normalized: Translation2D {
        func normalize(_ delta: Int) -> Int {
            guard delta != 0 else {
                return delta
            }
            
            return delta / abs(delta)
        }
        
        return Translation2D(deltaX: normalize(deltaX), deltaY: normalize(deltaY))
    }
}
