//
//  Day23.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-23.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

extension Commands {
    struct Day23: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day23",
                abstract: "Solve day 23 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let grid = Grid(rawValue: try readFile())!
            
            printTitle("Part 1", level: .title1)
            let numberOfEmptyGroundTilesOfAfter10Rounds = part1(grid: grid)
            print(
                "Simulate the Elves' process and find the smallest rectangle that contains the Elves after 10 rounds. How many empty ground tiles does that rectangle contain?",
                numberOfEmptyGroundTilesOfAfter10Rounds,
                terminator: "\n\n"
            )
            
            printTitle("Part 1", level: .title1)
            let firstRoundWhereNotElfMoves = part2(grid: grid)
            print(
                "Figure out where the Elves need to go. What is the number of the first round where no Elf moves?",
                firstRoundWhereNotElfMoves
            )
        }
        
        fileprivate func part1(grid: Grid) -> Int {
            let propositionsAndChecks: [(move: Translation2D, checks: [Translation2D])] = [
                (.north, [.north, .northEast, .northWest]),
                (.south, [.south, .southEast, .southWest]),
                (.west, [.west, .northWest, .southWest]),
                (.east, [.east, .northEast, .southEast]),
            ]
            let propositionCount = propositionsAndChecks.count
            
            var grid = grid
            for roundIndex in 0 ..< 10 {
                let propositionStartIndex = roundIndex % propositionsAndChecks.count
                let propositonIndices = (0 ..< 4).map({ offset in
                    ((propositionStartIndex + offset) % propositionCount + propositionCount) % propositionCount
                })
                
                var numberOfPropositionsByDestination = [Point2D: Int]()
                var proposedMoves = [Move]()
                
                for point in grid.occupiedPoints {
                    let availablePropositions = propositonIndices.lazy
                        .map({ propositionsAndChecks[$0] })
                        .filter({proposition in
                            proposition.checks.allSatisfy({ check in
                                !grid.occupiedPoints.contains(point.applying(check))
                            })
                        })
                    
                    if availablePropositions.isEmpty || availablePropositions.count == propositionCount {
                        continue
                    }
                    
                    let proposition = availablePropositions.first!
                    let move = Move(start: point, end: point.applying(proposition.move))
                    proposedMoves.append(move)
                    numberOfPropositionsByDestination[move.end, default: 0] += 1
                }
                
                
                let validMoves = proposedMoves.filter({ numberOfPropositionsByDestination[$0.end, default: 0] == 1 })
                for move in validMoves {
                    grid.occupiedPoints.remove(move.start)
                    grid.occupiedPoints.insert(move.end)
                }
            }
            
            return grid.numberOfEmptyPoints()
        }
        
        fileprivate func part2(grid: Grid) -> Int {
            let propositionsAndChecks: [(move: Translation2D, checks: [Translation2D])] = [
                (.north, [.north, .northEast, .northWest]),
                (.south, [.south, .southEast, .southWest]),
                (.west, [.west, .northWest, .southWest]),
                (.east, [.east, .northEast, .southEast]),
            ]
            let propositionCount = propositionsAndChecks.count
            
            var grid = grid
            
            return (0...).first(where: { roundIndex in
                let propositionStartIndex = roundIndex % propositionsAndChecks.count
                let propositonIndices = (0 ..< 4).map({ offset in
                    ((propositionStartIndex + offset) % propositionCount + propositionCount) % propositionCount
                })
                
                var numberOfPropositionsByDestination = [Point2D: Int]()
                var proposedMoves = [Move]()
                
                for point in grid.occupiedPoints {
                    let availablePropositions = propositonIndices.lazy
                        .map({ propositionsAndChecks[$0] })
                        .filter({proposition in
                            proposition.checks.allSatisfy({ check in
                                !grid.occupiedPoints.contains(point.applying(check))
                            })
                        })
                    
                    if availablePropositions.isEmpty || availablePropositions.count == propositionCount {
                        continue
                    }
                    
                    let proposition = availablePropositions.first!
                    let move = Move(start: point, end: point.applying(proposition.move))
                    proposedMoves.append(move)
                    numberOfPropositionsByDestination[move.end, default: 0] += 1
                }
                
                let validMoves = proposedMoves.filter({ numberOfPropositionsByDestination[$0.end, default: 0] == 1 })
                if validMoves.isEmpty {
                    return true
                }
                
                for move in validMoves {
                    grid.occupiedPoints.remove(move.start)
                    grid.occupiedPoints.insert(move.end)
                }
                
                return false
            })! + 1
        }
    }
}

fileprivate struct Grid {
    var occupiedPoints: Set<Point2D>
    
    var rangeOfX: ClosedRange<Int> {
        let xCoordinates = Set(occupiedPoints.map(\.x))
        return xCoordinates.min()! ... xCoordinates.max()!
    }
    var rangeOfY: ClosedRange<Int> {
        let yCoordinates = Set(occupiedPoints.map(\.y))
        return yCoordinates.min()! ... yCoordinates.max()!
    }
    
    func numberOfEmptyPoints() -> Int {
        product(rangeOfX, rangeOfY).count(where: { pair in
            let (x, y) = pair
            let point = Point2D(x: x, y: y)
            return !occupiedPoints.contains(point)
        })
    }
    
    var description: String {
        rangeOfY
            .map({ y -> String in
                rangeOfX.reduce(into: "", { result, x in
                    let point = Point2D(x: x, y: y)
                    if occupiedPoints.contains(point) {
                        result += "#"
                    }
                    else {
                        result += "."
                    }
                })
            })
            .joined(separator: "\n")
    }
}

fileprivate extension Grid {
    init?(rawValue: String) {
        let lines = rawValue.components(separatedBy: .newlines)
        self.occupiedPoints = lines.enumerated().reduce(into: [], { result, pair in
            let (y, line) = pair
            
            let occupiedPoints: Set<Point2D> = line.enumerated().reduce(into: [], { result, pair in
                let (x, character) = pair
                if character == "#" {
                    result.insert(Point2D(x: x, y: y))
                }
            })
            result.formUnion(occupiedPoints)
        })
    }
}

fileprivate extension Translation2D {
    static let north = Self(deltaX: 0, deltaY: -1)
    static let northEast = Self(deltaX: 1, deltaY: -1)
    static let east = Self(deltaX: 1, deltaY: 0)
    static let southEast = Self(deltaX: 1, deltaY: 1)
    static let south = Self(deltaX: 0, deltaY: 1)
    static let southWest = Self(deltaX: -1, deltaY: 1)
    static let west = Self(deltaX: -1, deltaY: 0)
    static let northWest = Self(deltaX: -1, deltaY: -1)
}

fileprivate struct Move {
    let start: Point2D
    let end: Point2D
}
