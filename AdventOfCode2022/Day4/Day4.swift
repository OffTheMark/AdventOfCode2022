//
//  Day4.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-04.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day4: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day4",
                abstract: "Solve day 4 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let sectionPairs: [(ClosedRange<Int>, ClosedRange<Int>)] = try readLines()
                .compactMap({ line in
                    let parts = line.components(separatedBy: ",")
                    assert(parts.count == 2, "count == 2")
                    
                    let firstRangeParts = parts[0].components(separatedBy: "-").compactMap(Int.init)
                    let secondRangeParts = parts[1].components(separatedBy: "-").compactMap(Int.init)
                    
                    return (firstRangeParts[0] ... firstRangeParts[1], secondRangeParts[0] ... secondRangeParts[1])
                })
            
            let numberOfAssignmentPairsWhereOneRangeContainsTheOther = part1(input: sectionPairs)
            printTitle("Part 1", level: .title1)
            print(
                "Number of assignment pairs where one range fully contains the other:",
                numberOfAssignmentPairsWhereOneRangeContainsTheOther,
                terminator: "\n\n"
            )
            
            let numberOfOverlappingAssignmentPairs = part2(input: sectionPairs)
            printTitle("Title 2", level: .title1)
            print("Number of overlapping assignment pairs:", numberOfOverlappingAssignmentPairs)
        }
        
        func part1(input: [(ClosedRange<Int>, ClosedRange<Int>)]) -> Int {
            input.count(where: { left, right in
                left.contains(right) || right.contains(left)
            })
        }
        
        func part2(input: [(ClosedRange<Int>, ClosedRange<Int>)]) -> Int {
            input.count(where: { left, right in
                left.overlaps(right)
            })
        }
    }
}

extension ClosedRange {
    func contains(_ other: ClosedRange<Bound>) -> Bool {
        lowerBound <= other.lowerBound && upperBound >= other.upperBound
    }
}
