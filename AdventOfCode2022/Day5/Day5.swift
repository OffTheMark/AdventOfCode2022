//
//  Day5.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-05.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day5: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day5",
                abstract: "Solve day 5 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let (stacks, moves) = try parse(input: try readFile())
            
            let cratesOnTopOfEachStack = part1(stacks: stacks, moves: moves)
            printTitle("Part 1", level: .title1)
            print(
                "After the rearrangement procedure completes, what crate ends up on top of each stack?",
                cratesOnTopOfEachStack,
                terminator: "\n\n"
            )
        }
        
        private func parse(input: String) throws -> (Stacks, [Move]) {
            let components = input.components(separatedBy: "\n\n")
            assert(components.count == 2, "count == 2")
            
            let stacks = parseStacks(input: components[0])
            let moves = try parseMoves(input: components[1])
            return (stacks, moves)
        }
        
        private func parseStacks(input: String) -> Stacks {
            var lines = input.components(separatedBy: .newlines)
            let lastLine = lines.removeLast()
            
            func column(forStackIdentifier identifier: Int) -> Int {
                (identifier - 1) * 4 + 1
            }
            
            let stackIdentifiers = lastLine
                .split(whereSeparator: { $0.isWhitespace })
                .compactMap({ Int(String($0)) })
            
            var stacks = Stacks()
            stackIdentifiers.forEach({
                stacks[$0] = []
            })
            
            for line in lines.reversed() {
                for identifier in stackIdentifiers {
                    let column = column(forStackIdentifier: identifier)
                    guard column <= line.count else {
                        continue
                    }
                    
                    let index = line.index(line.startIndex, offsetBy: column)
                    let crate = line[index]
                    
                    if crate != " " {
                        stacks[identifier, default: []].append(crate)
                    }
                }
            }
            
            return stacks
        }
        
        private func parseMoves(input: String) throws -> [Move] {
            let lines = input.components(separatedBy: .newlines)
            let pattern = #"move (\d+) from (\d) to (\d)"#
            let regularExpression = try NSRegularExpression(pattern: pattern)
            
            return lines.reduce(into: [Move](), { result, line in
                let range = NSRange(line.startIndex ..< line.endIndex, in: line)
                regularExpression.enumerateMatches(in: line, range: range, using: { match, _, stop in
                    guard let match, match.numberOfRanges == 4 else { return }
                    
                    guard let firstRange = Range(match.range(at: 1), in: line),
                          let secondRange = Range(match.range(at: 2), in: line),
                          let thirdRange = Range(match.range(at: 3), in: line),
                          let number = Int(line[firstRange]),
                          let start = Int(line[secondRange]),
                          let end = Int(line[thirdRange]) else {
                        return
                    }
                    
                    let move = Move(number: number, start: start, end: end)
                    result.append(move)
                })
            })
        }
        
        func part1(stacks: Stacks, moves: [Move]) -> String {
            var stacks = stacks
            
            for move in moves {
                for _ in 0 ..< move.number {
                    guard let crate = stacks[move.start]?.removeLast() else {
                        continue
                    }
                    
                    stacks[move.end, default: []].append(crate)
                }
            }
            
            return String(stacks.keys.sorted().compactMap({
                stacks[$0]?.last
            }))
        }
    }
    
    struct Move {
        let number: Int
        let start: Int
        let end: Int
    }
    
    typealias Stacks = [Int: [Character]]
}


