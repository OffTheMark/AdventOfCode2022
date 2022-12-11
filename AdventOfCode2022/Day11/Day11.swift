//
//  Day11.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-11.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

extension Commands {
    struct Day11: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day11",
                abstract: "Solve day 11 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let monkeys = try readFile().components(separatedBy: "\n\n").compactMap({ block in
                var lines = block.components(separatedBy: .newlines)
                lines.removeFirst()
                
                return Monkey(lines: lines)
            })
            
            let levelOfMonkeyBusinessAfter20Rounds = part1(monkeys: monkeys)
            printTitle("Part 1", level: .title1)
            print(
                "What is the level of monkey business after 20 rounds of stuff-slinging simian shenanigans?",
                levelOfMonkeyBusinessAfter20Rounds,
                terminator: "\n\n"
            )
            
            let levelOfMonkeyBusinessAfter10000Rounds = part2(monkeys: monkeys)
            printTitle("Part 2", level: .title1)
            print(
                "Worry levels are no longer divided by three after each item is inspected; hat is the level of monkey business after 10000 rounds?",
                levelOfMonkeyBusinessAfter10000Rounds,
                terminator: "\n\n"
            )
        }
        
        func part1(monkeys: [Monkey]) -> Int {
            var monkeys = monkeys
            let numberOfRounds = 20
            var inspectedItemsByMonkey = [Int: Int]()
            
            for _ in 0 ..< numberOfRounds {
                for index in monkeys.indices {
                    inspectedItemsByMonkey[index, default: 0] += monkeys[index].items.count
                    
                    while var item = monkeys[index].items.popFirst() {
                        item = monkeys[index].operation(item)
                        item /= 3
                        
                        let resultOfTest = monkeys[index].test(item)
                        let monkeyToThrow = monkeys[index].monkeyToThrow(resultOfTest)
                        monkeys[monkeyToThrow].items.append(item)
                    }
                }
            }
            
            return inspectedItemsByMonkey.values.sorted(by: >).prefix(2).reduce(1, *)
        }
        
        func part2(monkeys: [Monkey]) -> Int {
            var monkeys = monkeys
            let numberOfRounds = 10_000
            var inspectedItemsByMonkey = [Int: Int]()
            
            let modulo = monkeys.reduce(into: 1, { result, monkey in
                result *= monkey.divider
            })
            
            for _ in 0 ..< numberOfRounds {
                for index in monkeys.indices {
                    inspectedItemsByMonkey[index, default: 0] += monkeys[index].items.count
                    
                    while var item = monkeys[index].items.popFirst() {
                        item = monkeys[index].operation(item)
                        item %= modulo
                        
                        let resultOfTest = monkeys[index].test(item)
                        let monkeyToThrow = monkeys[index].monkeyToThrow(resultOfTest)
                        monkeys[monkeyToThrow].items.append(item)
                    }
                }
            }
            
            return inspectedItemsByMonkey.values.sorted(by: >).prefix(2).reduce(1, *)
        }
        
        struct Monkey {
            var items: Deque<Int>
            var operation: (Int) -> Int
            let divider: Int
            let monkeyToThrow: (Bool) -> Int
            
            func test(_ worryLevel: Int) -> Bool {
                worryLevel.isMultiple(of: divider)
            }
            
            init?(lines: [String]) {
                let lines = lines.map({ $0.trimmingCharacters(in: .whitespaces) })
                
                guard lines.count == 5 else {
                    return nil
                }
                
                let startingItems = lines[0].removingPrefix("Starting items: ")
                    .components(separatedBy: ", ")
                    .compactMap(Int.init)
                
                guard let operation = Self.operation(from: lines[1]) else {
                    return nil
                }
                
                guard let divider = Self.divider(from: lines[2]) else {
                    return nil
                }
                
                guard let monkeyToThrow = Self.monkeyToThrows(from: Array(lines[3 ... 4])) else {
                    return nil
                }
                
                self.items = Deque(startingItems)
                self.operation = operation
                self.divider = divider
                self.monkeyToThrow = monkeyToThrow
            }
            
            private static func operation(from line: String) -> ((Int) -> Int)? {
                let components = line.removingPrefix("Operation: new = old ").components(separatedBy: " ")
                
                guard components.count == 2 else {
                    return nil
                }
                
                switch components[0] {
                case "+":
                    if let number = Int(components[1]) {
                        return { $0 + number }
                    }
                    if components[1] == "old" {
                        return { $0 + $0 }
                    }
                    
                    return nil
                    
                case "*":
                    if let number = Int(components[1]) {
                        return { $0 * number }
                    }
                    if components[1] == "old" {
                        return { $0 * $0 }
                    }
                    
                    return nil
                    
                default:
                    return nil
                }
            }
            
            private static func divider(from line: String) -> Int? {
                let rawValue = line.removingPrefix("Test: divisible by ")
                return Int(rawValue)
            }
            
            private static func monkeyToThrows(from lines: [String]) -> ((Bool) -> Int)? {
                guard lines.count == 2 else {
                    return nil
                }
                
                guard let firstMonkey = Int(lines[0].removingPrefix("If true: throw to monkey ")) else {
                    return nil
                }
                
                guard let secondMonkey = Int(lines[1].removingPrefix("If false: throw to monkey ")) else {
                    return nil
                }
                    
                return { $0 ? firstMonkey : secondMonkey }
            }
        }
    }
}

extension String {
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }
        
        return String(dropFirst(prefix.count))
    }
}
