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
        }
        
        func part1(grid: Grid) -> Int {
            var visibleTrees = Set<Point2D>()
            
            for row in grid.rows {
                var greatestEncounteredHeight: Int?
                for column in grid.columns {
                    let point = Point2D(x: column, y: row)
                    
                    let height = grid.itemsByPoint[point, default: 0]
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
                    
                    let height = grid.itemsByPoint[point, default: 0]
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
                    
                    let height = grid.itemsByPoint[point, default: 0]
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
                    
                    let height = grid.itemsByPoint[point, default: 0]
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
    }
    
    struct Grid {
        var size: Size
        var itemsByPoint: [Point2D: Int]
        
        var columns: Range<Int> { 0 ..< size.width }
        
        var rows: Range<Int> { 0 ..< size.height }
        
        init(size: Size, itemsByPoint: [Point2D : Int]) {
            self.size = size
            self.itemsByPoint = itemsByPoint
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
            self.itemsByPoint = itemsByPoint
        }
    }
}

struct Point2D: Hashable {
    var x: Int
    var y: Int
}

struct Size {
    var width: Int
    var height: Int
}
