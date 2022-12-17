//
//  Day16.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

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
        
        func run() throws {
            let connections = try readLines().compactMap(ValveConnection.init)
            
            printTitle("Part 1", level: .title1)
            let highestReleasedPressure = part1(connections: connections)
            print(
                "Work out the steps to release the most pressure in 30 minutes. What is the most pressure you can release?",
                highestReleasedPressure,
                terminator: "\n\n"
            )
        }
        
        func part1(connections: [ValveConnection]) -> Int {
            // TODO: https://github.com/davearussell/advent2022/blob/master/day16/solve.py
            var connectedValvesByValve = [String: Set<String>]()
            var flowRateByValve = [String: Int]()
            
            for connection in connections {
                connectedValvesByValve[connection.valve] = connection.connectedValves
                flowRateByValve[connection.valve] = connection.flowRate
            }
            
            for (valve, flowRate) in flowRateByValve where valve != "AA" && flowRate <= 0 {
                flowRateByValve.removeValue(forKey: valve)
                
                for key in connectedValvesByValve.keys {
                    connectedValvesByValve[key, default: []].remove(valve)
                }
            }
            
            struct Path {
                let lastValve: String
                let openedValves: Set<String>
                let combinedFlowRate: Int
                let timeRemaining: Int
                
                func appendingValve(_ valve: String, withFlowRate flowRate: Int) -> Path {
                    var timeRemaining = timeRemaining
                    if openedValves.contains(valve) {
                        timeRemaining -= 1
                    }
                    else {
                        timeRemaining -= 2
                    }
                    
                    var combinedFlowRate = combinedFlowRate
                    if !openedValves.contains(valve) {
                        combinedFlowRate += timeRemaining * flowRate
                    }
                    
                    return Path(
                        lastValve: valve,
                        openedValves: openedValves.union([valve]),
                        combinedFlowRate: combinedFlowRate,
                        timeRemaining: timeRemaining
                    )
                }
            }
            
            let initialPath = Path(
                lastValve: "AA",
                openedValves: [],
                combinedFlowRate: 0,
                timeRemaining: 30
            )
            var frontier = Heap<Path>(
                array: [initialPath],
                sort: { $0.combinedFlowRate > $1.combinedFlowRate }
            )
            
            var highestFlowRates = Set<Int>()
            
            while let pathWithHighestFlowRate = frontier.remove() {
                if pathWithHighestFlowRate.timeRemaining == 0 {
                    highestFlowRates.insert(pathWithHighestFlowRate.combinedFlowRate)
                    continue
                }
                
                let neighbors = connectedValvesByValve[pathWithHighestFlowRate.lastValve, default: []]
                for neighbor in neighbors {
                    let newPath = pathWithHighestFlowRate.appendingValve(
                        neighbor,
                        withFlowRate: flowRateByValve[neighbor, default: 0]
                    )
                    
                    guard newPath.timeRemaining >= 0 else {
                        continue
                    }
                    
                    frontier.insert(newPath)
                }
            }
            
            return highestFlowRates.max()!
        }
        
        struct ValveConnection {
            let valve: String
            let flowRate: Int
            let connectedValves: [String]
            
            init?(rawValue: String) {
                let components = rawValue.components(separatedBy: "; ")
                guard components.count == 2 else {
                    return nil
                }
                
                self.connectedValves = components[1]
                    .removingPrefix("tunnels lead to valve")
                    .removingPrefix("s")
                    .removingPrefix(" ")
                    .components(separatedBy: ", ")
                
                let firstPartComponents = components[0].components(separatedBy: " ")
                guard firstPartComponents.count == 5 else {
                    return nil
                }
                
                self.valve = firstPartComponents[1]
                
                guard let flowRate = Int(firstPartComponents[4].removingPrefix("rate=")) else {
                    return nil
                }
                
                self.flowRate = flowRate
            }
        }
    }
}
