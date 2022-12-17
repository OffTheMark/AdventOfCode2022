//
//  Day16.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms
import Collections

extension Commands {
    struct Day16: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day16",
                abstract: "Solve day 16 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        mutating func run() throws {
            let valves = try readLines().compactMap(Valve.init)
            let valvesByName = valves.reduce(into: [:], { result, valve in
                result[valve.name] = valve
            })
            
            printTitle("Part 1", level: .title1)
            let (highestReleasedPressureAlone, cache) = part1(valvesByName: valvesByName)
            print(
                "Work out the steps to release the most pressure in 30 minutes. What is the most pressure you can release?",
                highestReleasedPressureAlone,
                terminator: "\n\n"
            )
        }
        
        // https://www.reddit.com/r/adventofcode/comments/zn6k1l/comment/j0fpyu4/
        mutating func part1(valvesByName: [String: Valve]) -> (Int, [CacheKey: Int]) {
            var cache = [CacheKey: Int]()
            
            func visit(openedValves: Set<String>, timeRemaining: Int, current: String) -> Int {
                let cacheKey = CacheKey(
                    openedValves: openedValves,
                    timeRemaining: timeRemaining,
                    current: current
                )
                if let cachedValue = cache[cacheKey] {
                    return cachedValue
                }
                
                if timeRemaining <= 0 {
                    return 0
                }
                
                var best = 0
                let valve = valvesByName[current]!
                
                for neighbor in valve.connectedValves {
                    let candidate = visit(
                        openedValves: openedValves,
                        timeRemaining: timeRemaining - 1,
                        current: neighbor
                    )
                    best = max(best, candidate)
                }
                
                if !openedValves.contains(current), valve.flowRate > 0, timeRemaining > 0 {
                    let timeRemaining = timeRemaining - 1
                    let newSum = timeRemaining * valve.flowRate
                    
                    for neighbor in valve.connectedValves {
                        let candidate = newSum + visit(
                            openedValves: openedValves.union([current]),
                            timeRemaining: timeRemaining - 1,
                            current: neighbor
                        )
                        best = max(best, candidate)
                    }
                }
                
                cache[cacheKey] = best
                return best
            }
            
            let best = visit(openedValves: [], timeRemaining: 30, current: "AA")
            return (best, cache)
        }
        
        struct CacheKey: Hashable, Decodable {
            let openedValves: Set<String>
            let timeRemaining: Int
            let current: String
        }
        
        struct Valve: Decodable {
            let name: String
            let flowRate: Int
            let connectedValves: Set<String>
            
            init?(rawValue: String) {
                let components = rawValue.components(separatedBy: "; ")
                guard components.count == 2 else {
                    return nil
                }
                
                self.connectedValves = Set(
                    components[1]
                        .removingPrefix("tunnels lead to valves ")
                        .removingPrefix("tunnel leads to valve ")
                        .components(separatedBy: ", ")
                )
                
                let firstPartComponents = components[0].components(separatedBy: " ")
                guard firstPartComponents.count == 5 else {
                    return nil
                }
                
                self.name = firstPartComponents[1]
                
                guard let flowRate = Int(firstPartComponents[4].removingPrefix("rate=")) else {
                    return nil
                }
                
                self.flowRate = flowRate
            }
        }
    }
}
