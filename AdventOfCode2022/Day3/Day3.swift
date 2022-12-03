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
            
            let sumOfPriorities = part1(input: input)
            printTitle("Part 1", level: .title1)
            print("Sum of priorities:", sumOfPriorities, terminator: "\n\n")
        }
        
        func part1(input: [Rucksack]) -> Int {
            input.reduce(into: 0, { result, rucksack in
                let itemsAppearingInBothHalves = Set(rucksack.firstHalf)
                    .intersection(Set(rucksack.secondHalf))
                assert(itemsAppearingInBothHalves.count == 1)
                
                let priority = Self.prioritiesByItem[itemsAppearingInBothHalves.first!, default: 0]
                result += priority
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
