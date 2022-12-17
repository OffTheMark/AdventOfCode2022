//
//  Day17.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

extension Commands {
    struct Day17: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day17",
                abstract: "Solve day 17 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        private static let shapes: [Rock] = [
            .horizontalLine,
            .cross,
            .corner,
            .verticalLine,
            .square,
        ]
        
        func run() throws {
            let moves: [Translation2D] = try readFile().compactMap({ character in
                switch character {
                case "<":
                    return .left
                
                case ">":
                    return .right
                    
                default:
                    return nil
                }
            })
            
            printTitle("Part 1", level: .title1)
            let heightOfTowerOf2022Rocks = part1(moves: moves)
            print(
                "How many units tall will the tower of rocks be after 2022 rocks have stopped falling?",
                heightOfTowerOf2022Rocks,
                terminator: "\n\n"
            )
        }
        
        func part1(moves: [Translation2D]) -> Int {
            simulate(moves: moves, steps: 2022)
        }
        
        func simulate(moves: [Translation2D], steps: Int) -> Int {
            var restingRocks = Set<Point2D>()
            var height = 0
            let numberOfMoves = moves.count
            let numberOfShapes = Self.shapes.count
            
            func isCollidingLaterally(_ rock: Rock) -> Bool {
                rock.contains(where: { point in
                    if !(0 ..< 7).contains(point.x) {
                        return true
                    }
                    
                    if point.y <= 0 {
                        return true
                    }
                    
                    return restingRocks.contains(point)
                })
            }
            
            func isCollidingVertically(_ rock: Rock) -> Bool {
                rock.contains(where: { point in
                    if point.y <= 0 {
                        return true
                    }
                    
                    return restingRocks.contains(point)
                })
            }
            
            var moveIndex = 0 {
                didSet {
                    moveIndex %= numberOfMoves
                }
            }
            for step in 0 ..< steps {
                let shapeIndex = step % numberOfShapes
                
                let initialTranslation = Translation2D(deltaX: 2, deltaY: height + 4)
                var rock = Self.shapes[shapeIndex].applying(initialTranslation)
                
                alternatingMoves: for isLateralMove in [true, false].cycled() {
                    let translation: Translation2D
                    if isLateralMove {
                        translation = moves[moveIndex]
                        moveIndex += 1
                    }
                    else {
                        translation = .down
                    }
                    
                    let movedRock = rock.applying(translation)
                    if isLateralMove {
                        if !isCollidingLaterally(movedRock) {
                            rock = movedRock
                        }
                        
                        continue
                    }
                    
                    if isCollidingVertically(movedRock) {
                        break alternatingMoves
                    }
                    
                    rock = movedRock
                }
                
                restingRocks.formUnion(rock)
                height = max(height, rock.map(\.y).max()!)
            }
            
            printChamber(restingRocks: restingRocks)
            
            return height
        }
        
        private func printChamber(restingRocks: Set<Point2D>) {
            let rangeOfX = -1 ... 7
            let rangeOfY = 0 ... (restingRocks.map(\.y).max() ?? 0)
            
            let lines: [String] = rangeOfY.reversed().map({ y in
                String(rangeOfX.map({ x in
                    let point = Point2D(x: x, y: y)
                    
                    let isXWall = !(0 ..< 7).contains(point.x)
                    let isYFloor = point.y <= 0
                    
                    switch (isXWall, isYFloor) {
                    case (true, true):
                        return "+"
                        
                    case (true, false):
                        return "|"
                        
                    case (false, true):
                        return "-"
                        
                    default:
                        return restingRocks.contains(point) ? "#" : "."
                    }
                }))
                
            })
            
            print(lines.joined(separator: "\n"), terminator: "\n\n")
        }
    }
}

fileprivate typealias Rock = Set<Point2D>

fileprivate extension Rock {
    static let horizontalLine = Self((0...3).map({ Point2D(x: $0, y: 0) }))
    
    static let cross: Self = [
        .init(x: 1, y: 0),
        .init(x: 0, y: 1),
        .init(x: 1, y: 1),
        .init(x: 2, y: 1),
        .init(x: 1, y: 2),
    ]
    
    static let corner: Self = [
        .init(x: 0, y: 0),
        .init(x: 1, y: 0),
        .init(x: 2, y: 0),
        .init(x: 2, y: 1),
        .init(x: 2, y: 2),
    ]
    
    static let verticalLine = Self((0...3).map({ Point2D(x: 0, y: $0) }))
    
    static let square = Self(product(0...1, 0...1).map({ Point2D(x: $0, y: $1) }))
    
    func applying(_ translation: Translation2D) -> Self {
        Self(map({ $0.applying(translation) }))
    }
    
    var minX: Int? { map(\.x).min() }
    var maxX: Int? { map(\.x).max() }
}

fileprivate extension Translation2D {
    static let up = Self(deltaX: 0, deltaY: 1)
    static let down = Self(deltaX: 0, deltaY: -1)
    static let left = Self(deltaX: -1, deltaY: 0)
    static let right = Self(deltaX: 1, deltaY: 0)
}
