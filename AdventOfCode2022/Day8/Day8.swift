//
//  Day8.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-08.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

extension Commands {
    struct Day8: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day8",
                abstract: "Solve day 8 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let grid = Grid(lines: try readLines())
            
            let numberOfTreesVisibleFromOutsideTheGrid = part1(grid: grid)
            printTitle("Part 1", level: .title1)
            print(
                "How many trees are visible from outside the grid?",
                numberOfTreesVisibleFromOutsideTheGrid,
                terminator: "\n\n"
            )
            
            let highestScenicScore = part2(grid: grid)
            printTitle("Part 2", level: .title1)
            print(
                "What is the highest scenic score possible for any tree?",
                highestScenicScore
            )
        }
        
        fileprivate func part1(grid: Grid) -> Int {
            var visibleTrees = Set<Point2D>()
            
            for row in grid.rows {
                var greatestEncounteredHeight: Int?
                for column in grid.columns {
                    let point = Point2D(x: column, y: row)
                    
                    let height = grid.height(of: point)
                    let isHighestEncounteredTree: Bool
                    if let greatestEncounteredHeight {
                        isHighestEncounteredTree = height > greatestEncounteredHeight
                    }
                    else {
                        isHighestEncounteredTree = true
                    }
                    
                    if isHighestEncounteredTree {
                        greatestEncounteredHeight = height
                        visibleTrees.insert(point)
                    }
                }
            }
            for row in grid.rows {
                var greatestEncounteredHeight: Int?
                for column in grid.columns.reversed() {
                    let point = Point2D(x: column, y: row)
                    
                    let height = grid.height(of: point)
                    let isHighestEncounteredTree: Bool
                    if let greatestEncounteredHeight {
                        isHighestEncounteredTree = height > greatestEncounteredHeight
                    }
                    else {
                        isHighestEncounteredTree = true
                    }
                    
                    if isHighestEncounteredTree {
                        greatestEncounteredHeight = height
                        visibleTrees.insert(point)
                    }
                }
            }
            
            for column in grid.columns {
                var greatestEncounteredHeight: Int?
                for row in grid.rows {
                    let point = Point2D(x: column, y: row)
                    
                    let height = grid.height(of: point)
                    let isHighestEncounteredTree: Bool
                    if let greatestEncounteredHeight {
                        isHighestEncounteredTree = height > greatestEncounteredHeight
                    }
                    else {
                        isHighestEncounteredTree = true
                    }
                    
                    if isHighestEncounteredTree {
                        greatestEncounteredHeight = height
                        visibleTrees.insert(point)
                    }
                }
            }
            
            for column in grid.columns {
                var greatestEncounteredHeight: Int?
                for row in grid.rows.reversed() {
                    let point = Point2D(x: column, y: row)
                    
                    let height = grid.height(of: point)
                    let isHighestEncounteredTree: Bool
                    if let greatestEncounteredHeight {
                        isHighestEncounteredTree = height > greatestEncounteredHeight
                    }
                    else {
                        isHighestEncounteredTree = true
                    }
                    
                    if isHighestEncounteredTree {
                        greatestEncounteredHeight = height
                        visibleTrees.insert(point)
                    }
                }
            }
            
            return visibleTrees.count
        }
        
        fileprivate func part2(grid: Grid) -> Int {
            let scenicScoresByPoint = grid.scenicScoresByPoint()
            return scenicScoresByPoint.values.max()!
        }
    }
}

fileprivate struct Grid {
    var size: Size
    var heightsByPoint: [Point2D: Int]
    
    var columns: Range<Int> { 0 ..< size.width }
    
    var rows: Range<Int> { 0 ..< size.height }
    
    init(size: Size, itemsByPoint: [Point2D : Int]) {
        self.size = size
        self.heightsByPoint = itemsByPoint
    }
    
    func contains(_ point: Point2D) -> Bool {
        heightsByPoint[point] != nil
    }
    
    func height(of point: Point2D) -> Int {
        heightsByPoint[point, default: 0]
    }
    
    init(lines: [String]) {
        var size = Size(width: 0, height: lines.count)
        var itemsByPoint = [Point2D: Int]()
        
        for (row, line) in lines.enumerated() {
            size.width = max(size.width, line.count)
            
            for (column, item) in line.enumerated() {
                guard let item = Int(String(item)) else {
                    continue
                }
                let point = Point2D(x: column, y: row)
                itemsByPoint[point] = item
            }
        }
        
        self.size = size
        self.heightsByPoint = itemsByPoint
    }
    
    func scenicScoresByPoint() -> [Point2D: Int] {
        heightsByPoint.keys.reduce(into: [:], { result, point in
            result[point] = scenicScore(of: point)
        })
    }
    
    func scenicScore(of point: Point2D) -> Int {
        let directions: [Translation2D] = [.up, .down, .left, .right]
        var viewingDistanceByDirection = [Translation2D: Int]()
        
        for direction in directions {
            var currentPoint = point
            currentPoint.apply(direction)
            var viewingDistance = 0
            var hasHitTreeHigherOrEqual = false
            
            while contains(currentPoint), !hasHitTreeHigherOrEqual {
                viewingDistance += 1
                hasHitTreeHigherOrEqual = height(of: currentPoint) >= height(of: point)
                currentPoint.apply(direction)
            }
            
            viewingDistanceByDirection[direction] = viewingDistance
        }
        
        return viewingDistanceByDirection.values.reduce(1, *)
    }
}

struct Point2D: Hashable {
    var x: Int
    var y: Int
    
    static let zero = Self(x: 0, y: 0)
    
    mutating func apply(_ translation: Translation2D) {
        x += translation.deltaX
        y += translation.deltaY
    }
    
    func applying(_ translation: Translation2D) -> Self {
        var copy = self
        copy.apply(translation)
        return copy
    }
}

struct Translation2D: Hashable {
    var deltaX: Int
    var deltaY: Int
}

fileprivate extension Translation2D {
    static let up = Self(deltaX: 0, deltaY: -1)
    static let down = Self(deltaX: 0, deltaY: 1)
    static let left = Self(deltaX: -1, deltaY: 0)
    static let right = Self(deltaX: 1, deltaY: 0)
}

struct Size {
    var width: Int
    var height: Int
}
