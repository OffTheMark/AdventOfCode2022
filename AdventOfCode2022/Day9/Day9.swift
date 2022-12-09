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
            
            let numberOfPositionsVisitedByTail = part1(moves: moves)
            printTitle("Part 1", level: .title1)
            print(
                "How many positions does the tail of the rope visit at least once?",
                numberOfPositionsVisitedByTail,
                terminator: "\n\n"
            )
        }
        
        func part1(moves: [Move]) -> Int {
            var headPosition: Point2D = .zero
            var tailPosition = headPosition
            
            var visitedPositions: Set = [tailPosition]
            
            for move in moves {
                for _ in 0 ..< move.distance {
                    headPosition.apply(move.translation)
                    
                    if !tailPosition.touches(headPosition) {
                        let translationToHead = tailPosition.translation(to: headPosition)
                        
                        tailPosition.apply(translationToHead.normalized)
                    }
                    
                    visitedPositions.insert(tailPosition)
                }
            }
            
            return visitedPositions.count
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

extension Translation2D {
    static func *= (lhs: inout Translation2D, rhs: Int) {
        lhs.deltaX *= rhs
        lhs.deltaY *= rhs
    }
    
    static func * (lhs: Translation2D, rhs: Int) -> Translation2D {
        var result = lhs
        result *= rhs
        return lhs
    }
    
    var isDiagonal: Bool {
        deltaX != 0 || deltaX != 0
    }
    
    var normalized: Translation2D {
        let newDeltaX: Int
        if deltaX == 0 {
            newDeltaX = deltaX
        }
        else {
            newDeltaX = deltaX / abs(deltaX)
        }
        
        let newDeltaY: Int
        if deltaY == 0 {
            newDeltaY = deltaY
        }
        else {
            newDeltaY = deltaY / abs(deltaY)
        }
        
        return Translation2D(deltaX: newDeltaX, deltaY: newDeltaY)
    }
}
