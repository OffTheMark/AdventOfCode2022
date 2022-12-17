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
            let highestReleasedPressureAlone = part1(valvesByName: valvesByName)
            print(
                "Work out the steps to release the most pressure in 30 minutes. What is the most pressure you can release?",
                highestReleasedPressureAlone,
                terminator: "\n\n"
            )
            
            printTitle("Part 2", level: .title1)
            let highestReleasedPressureWithElephant = part2(valvesByName: valvesByName)
            print(
                "With you and an elephant working together for 26 minutes, what is the most pressure you could release?",
                highestReleasedPressureWithElephant
            )
        }
        
        // https://www.reddit.com/r/adventofcode/comments/zn6k1l/comment/j0g55m3/
        mutating func part1(valvesByName: [String: Valve]) -> Int {
            struct State {
                let elapsedTime: Int
                let valve: String
                let pressure: Int
                let openedValves: Set<String>
                
                var visited: Visited {
                    Visited(
                        elapsedTime: elapsedTime,
                        valve: valve
                    )
                }
            }
            struct Visited: Hashable {
                let elapsedTime: Int
                let valve: String
            }
            
            func flowRate(for openedValves: any Sequence<String>) -> Int {
                openedValves.reduce(into: 0, { sum, valve in
                    sum += valvesByName[valve]!.flowRate
                })
            }
            
            var queue: Deque<State> = [.init(
                elapsedTime: 1,
                valve: "AA",
                pressure: 0,
                openedValves: []
            )]
            var bestPressureByVisited = [Visited: Int]()
            var bestPressure = 0
            
            while let state = queue.popFirst() {
                let visited = state.visited
                if let best = bestPressureByVisited[visited], best >= state.pressure {
                    continue
                }
                bestPressureByVisited[visited] = state.pressure
                
                if state.elapsedTime >= 30 {
                    bestPressure = max(bestPressure, state.pressure)
                    continue
                }
                
                // We open the current valve if it is not opened
                if valvesByName[state.valve]!.flowRate > 0, !state.openedValves.contains(state.valve) {
                    let openedValves = state.openedValves.union([state.valve])
                    let pressure = state.pressure + flowRate(for: openedValves)
                    let newState = State(
                        elapsedTime: state.elapsedTime + 1,
                        valve: state.valve,
                        pressure: pressure,
                        openedValves: openedValves
                    )
                    queue.append(newState)
                }
                
                // We don't open the current valve but rather move to another valve.
                let pressure = state.pressure + flowRate(for: state.openedValves)
                for neighbor in valvesByName[state.valve]!.connectedValves {
                    let newState = State(
                        elapsedTime: state.elapsedTime + 1,
                        valve: neighbor,
                        pressure: pressure,
                        openedValves: state.openedValves
                    )
                    queue.append(newState)
                }
            }
            
            return bestPressure
        }
        
        mutating func part2(valvesByName: [String: Valve]) -> Int {
            struct State {
                let elapsedTime: Int
                let valve: String
                let elephantValve: String
                let pressure: Int
                let openedValves: Set<String>
                
                var visited: Visited {
                    Visited(
                        elapsedTime: elapsedTime,
                        valve: valve,
                        elephantValve: elephantValve
                    )
                }
            }
            
            struct Visited: Hashable {
                let elapsedTime: Int
                let valve: String
                let elephantValve: String
            }
            
            func flowRate(for openedValves: any Sequence<String>) -> Int {
                openedValves.reduce(into: 0, { sum, valve in
                    sum += valvesByName[valve]!.flowRate
                })
            }
            
            var queue: Deque<State> = [.init(
                elapsedTime: 1,
                valve: "AA",
                elephantValve: "AA",
                pressure: 0,
                openedValves: []
            )]
            var bestPressureByVisited = [Visited: Int]()
            var bestPressure = 0
            
            let maximumFlowRate = valvesByName.values.reduce(into: 0, { sum, valve in
                sum += valve.flowRate
            })
            
            while let state = queue.popFirst() {
                let visited = state.visited
                if let best = bestPressureByVisited[visited], best >= state.pressure {
                    continue
                }
                bestPressureByVisited[visited] = state.pressure
                
                if state.elapsedTime >= 26 {
                    bestPressure = max(bestPressure, state.pressure)
                    continue
                }
                
                // All valves are opened. So we wait and let the pressure build.
                let currentFlow = flowRate(for: state.openedValves)
                if currentFlow >= maximumFlowRate {
                    var pressure = state.pressure + currentFlow
                    var elapsedTime = state.elapsedTime
                    while elapsedTime < 25 {
                        elapsedTime += 1
                        pressure += currentFlow
                    }
                    let newState = State(
                        elapsedTime: elapsedTime + 1,
                        valve: state.valve,
                        elephantValve: state.elephantValve,
                        pressure: pressure,
                        openedValves: state.openedValves
                    )
                    queue.append(newState)
                    continue
                }
                
                // We open our current valve.
                if valvesByName[state.valve]!.flowRate > 0, !state.openedValves.contains(state.valve) {
                    var openedValves = state.openedValves.union([state.valve])
                    
                    // The elephant opens its current valve.
                    if valvesByName[state.elephantValve]!.flowRate > 0, !openedValves.contains(state.elephantValve) {
                        openedValves.insert(state.elephantValve)
                    
                        let pressure = state.pressure + flowRate(for: openedValves)
                        let newState = State(
                            elapsedTime: state.elapsedTime + 1,
                            valve: state.valve,
                            elephantValve: state.elephantValve,
                            pressure: pressure,
                            openedValves: openedValves
                        )
                        queue.append(newState)
                        
                        openedValves.remove(state.elephantValve)
                    }
                    
                    // The elephant doesn't open its current valve but rather moves to another valve.
                    let pressure = state.pressure + flowRate(for: openedValves)
                    for neighbor in valvesByName[state.elephantValve]!.connectedValves {
                        let newState = State(
                            elapsedTime: state.elapsedTime + 1,
                            valve: state.valve,
                            elephantValve: neighbor,
                            pressure: pressure,
                            openedValves: openedValves
                        )
                        queue.append(newState)
                    }
                }
                
                // We don't open our current valve but rather move to another valve.
                for ourNeighbor in valvesByName[state.valve]!.connectedValves {
                    var openedValves = state.openedValves
                    
                    // The elephant opens its current valve.
                    if valvesByName[state.elephantValve]!.flowRate > 0, !openedValves.contains(state.elephantValve) {
                        openedValves.insert(state.elephantValve)
                        
                        let pressure = state.pressure + flowRate(for: openedValves)
                        let newState = State(
                            elapsedTime: state.elapsedTime + 1,
                            valve: ourNeighbor,
                            elephantValve: state.elephantValve,
                            pressure: pressure,
                            openedValves: openedValves
                        )
                        queue.append(newState)
                        
                        openedValves.remove(state.elephantValve)
                    }
                    
                    // The elephant doesn't open its current valve but rather moves to another valve.
                    let pressure = state.pressure + flowRate(for: openedValves)
                    for elephantNeighbor in valvesByName[state.elephantValve]!.connectedValves {
                        let newState = State(
                            elapsedTime: state.elapsedTime + 1,
                            valve: ourNeighbor,
                            elephantValve: elephantNeighbor,
                            pressure: pressure,
                            openedValves: openedValves
                        )
                        queue.append(newState)
                    }
                }
            }
            
            return bestPressure
        }
    
        struct Valve {
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
