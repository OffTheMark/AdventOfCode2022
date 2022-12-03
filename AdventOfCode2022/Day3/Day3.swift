//
//  Day3.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-03.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day3: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day3",
                abstract: "Solve day 3 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        private static let prioritiesByItem: [Character: Int] = {
            let lowercaseItems = "abcdefghijklmnopqrstuvwxyz"
            let uppercaseItems = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            
            var prioritiesByCharacter = [Character: Int](uniqueKeysWithValues: zip(lowercaseItems, 1...))
            for (item, priority) in zip(uppercaseItems, 27...) {
                prioritiesByCharacter[item] = priority
            }
            
            return prioritiesByCharacter
        }()
        
        func run() throws {
            let input: [Rucksack] = try readLines().map({ Rucksack(items: Array($0)) })
            
            let sumOfPrioritiesForItemsInBothCompartments = part1(input: input)
            printTitle("Part 1", level: .title1)
            print(
                "Sum of priorities for items in both compartements:",
                sumOfPrioritiesForItemsInBothCompartments,
                terminator: "\n\n"
            )
            
            let sumOfPrioritiesForCommonItemsInGroups = part2(input: input)
            printTitle("Title 2", level: .title1)
            print(
                "Sum of priorities for common items in groups:",
                sumOfPrioritiesForCommonItemsInGroups,
                terminator: "\n\n"
            )
        }
        
        func part1(input: [Rucksack]) -> Int {
            input.reduce(into: 0, { result, rucksack in
                let itemsAppearingInBothHalves = Set(rucksack.firstHalf)
                    .intersection(Set(rucksack.secondHalf))
                assert(itemsAppearingInBothHalves.count == 1, "count == 1")
                
                let priority = Self.prioritiesByItem[itemsAppearingInBothHalves.first!, default: 0]
                result += priority
            })
        }
        
        func part2(input: [Rucksack]) -> Int {
            assert(input.count.isMultiple(of: 3), "isMultiple(of: 3)")
            
            return sequence(
                first: 0,
                next: { current in
                    let next = current + 3
                    if next >= input.endIndex {
                        return nil
                    }
                    return next
                }
            )
            .reduce(into: 0, { result, startIndex in
                let itemsAppearingInAllRucksacksOfGroup = Set(input[startIndex].items)
                    .intersection(Set(input[startIndex.advanced(by: 1)].items))
                    .intersection(Set(input[startIndex.advanced(by: 2)].items))
                
                assert(itemsAppearingInAllRucksacksOfGroup.count == 1, "count == 1")
                
                result += Self.prioritiesByItem[itemsAppearingInAllRucksacksOfGroup.first!, default: 0]
            })
        }
    }
}

struct Rucksack {
    var items = [Character]()
    
    var midPoint: Array<Character>.Index { items.endIndex / 2 }
    
    var firstHalf: ArraySlice<Character> { items[items.startIndex ..< midPoint] }
    
    var secondHalf: ArraySlice<Character> { items[midPoint ..< items.endIndex] }
}
