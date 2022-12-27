//
//  Day19.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-25.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day19: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day19",
                abstract: "Solve day 19 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let blueprints = try readLines().compactMap(Blueprint.init)
            
            printTitle("Title 1", level: .title1)
            let sumOfQualityLevels = part1(blueprints: blueprints)
            print(
                "Determine the quality level of each blueprint using the largest number of geodes it could produce in 24 minutes. What do you get if you add up the quality level of all of the blueprints in your list?",
                sumOfQualityLevels,
                terminator: "\n\n"
            )
            
            printTitle("Part 2", level: .title1)
            let product = part2(blueprints: blueprints)
            print(
                "Determine the largest number of geodes you could open using each of the first three blueprints. What do you get if you multiply these numbers together?",
                product
            )
        }
        
        fileprivate func part1(blueprints: [Blueprint]) -> Int {
            blueprints.reduce(into: 0, { sum, blueprint in
                let largestNumberOfGeodesProduced = largestNumberOfGeodesProduced(with: blueprint, inMinutes: 24)
                sum += blueprint.id * largestNumberOfGeodesProduced
            })
        }
        
        fileprivate func part2(blueprints: [Blueprint]) -> Int {
            blueprints.prefix(3).reduce(into: 1, { product, blueprint in
                let largestNumberOfGeodesProduced = largestNumberOfGeodesProduced(with: blueprint, inMinutes: 32)
                product *= largestNumberOfGeodesProduced
            })
        }
        
        // Based on https://www.reddit.com/r/adventofcode/comments/zpihwi/comment/j0vvtdt/
        private func largestNumberOfGeodesProduced(with blueprint: Blueprint, inMinutes numberOfMinutes: Int) -> Int {
            let maximumNeededByMineral = blueprint.maxAmountNeededByMineral()
            
            struct SearchState {
                var timeRemaining: Int
                var robots: [Mineral: Int]
                var minerals: [Mineral: Int]
                
                func optimisticBestAmount(of mineral: Mineral) -> Int {
                    minerals[mineral, default: 0]
                    + robots[mineral, default: 0]
                    + timeRemaining * (timeRemaining - 1)
                }
                
                func canBuildRobot(
                    _ robot: Mineral,
                    blueprint: Blueprint,
                    maximumNeededByMineral: [Mineral: Int]
                ) -> Bool {
                    let cost = blueprint.costsByRobot[robot]!
                    let isMaxedOut = robots[robot, default: 0] >= maximumNeededByMineral[robot, default: 0]
                    
                    if isMaxedOut {
                        return false
                    }
                    
                    return cost.allSatisfy({ mineral, amount in
                        minerals[mineral, default: 0] >= amount
                    })
                }
                
                func nextStateByBuildingRobot(_ robot: Mineral, blueprint: Blueprint) -> Self {
                    var minerals = minerals
                    minerals.merge(robots, uniquingKeysWith: { $0 + $1 })
                    
                    var robots = robots
                    robots[robot, default: 0] += 1
                    minerals.merge(
                        blueprint.costsByRobot[robot, default: [:]],
                        uniquingKeysWith: { $0 + $1 }
                    )
                    
                    return Self(
                        timeRemaining: timeRemaining - 1,
                        robots: robots,
                        minerals: minerals
                    )
                }
                
                func nextStateByBuildingNothing() -> Self {
                    var minerals = minerals
                    minerals.merge(robots, uniquingKeysWith: { $0 + $1 })
                    
                    return Self(
                        timeRemaining: timeRemaining - 1,
                        robots: robots,
                        minerals: minerals
                    )
                }
                
                mutating func buildRobot(_ robot: Mineral, blueprint: Blueprint) {
                    robots[robot, default: 0] += 1
                    minerals.merge(
                        blueprint.costsByRobot[robot, default: [:]],
                        uniquingKeysWith: { $0 - $1 }
                    )
                }
                
                mutating func unbuildRobot(_ robot: Mineral, blueprint: Blueprint) {
                    robots[robot, default: 0] -= 1
                    minerals.merge(
                        blueprint.costsByRobot[robot, default: [:]],
                        uniquingKeysWith: { $0 + $1 }
                    )
                }
            }
            
            func depthFirstSearch(
                state: SearchState,
                previousSkippedAvailableRobots: Set<Mineral>? = nil,
                bestSoFar: Int
            ) -> Int {
                // Even if we built a geode robot now, there is not enough time remanining for it to produce a geode, we
                // can stop searching and instead add the geodes produced by the current geode robots.
                if state.timeRemaining == 1 {
                    return state.minerals[.geode, default: 0] + state.robots[.geode, default: 0]
                }
                
                // If the optimistic expect score for this branch worse than the best score so far, we don't need to
                // search further and we can prune the state.
                if state.optimisticBestAmount(of: .geode) < bestSoFar {
                    return 0
                }
                
                // If we cannot generate enough obsidian to produce any more geode robots, we can already calculate the
                // maximum amount of geodes than can be produced with this state.
                if state.optimisticBestAmount(of: .obsidian) < maximumNeededByMineral[.obsidian, default: 0] {
                    return state.minerals[.geode, default: 0] + state.robots[.geode, default: 0] * state.timeRemaining
                }
                
                // Prepare the next state by decrementing the time remaining and updating the minerals produced.
                var nextState = state
                nextState.timeRemaining -= 1
                nextState.minerals.merge(nextState.robots, uniquingKeysWith: { $0 + $1 })
                
                if state.canBuildRobot(.geode, blueprint: blueprint, maximumNeededByMineral: maximumNeededByMineral) {
                    nextState.buildRobot(.geode, blueprint: blueprint)
                    return depthFirstSearch(
                        state: nextState,
                        bestSoFar: bestSoFar
                    )
                }
                
                let availableRobots: [Mineral] = [.ore, .clay, .obsidian].filter({ robot in
                    state.canBuildRobot(
                        robot,
                        blueprint: blueprint,
                        maximumNeededByMineral: maximumNeededByMineral
                    )
                })
                var best = bestSoFar
                
                for robot in availableRobots {
                    if let previousSkippedAvailableRobots, previousSkippedAvailableRobots.contains(robot) {
                        continue
                    }
                    
                    nextState.buildRobot(robot, blueprint: blueprint)
                    let score = depthFirstSearch(state: nextState, bestSoFar: bestSoFar)
                    best = max(best, score)
                    nextState.unbuildRobot(robot, blueprint: blueprint)
                }
                
                let score = depthFirstSearch(
                    state: nextState,
                    previousSkippedAvailableRobots: Set(availableRobots),
                    bestSoFar: best
                )
                best = max(score, best)
                return best
            }
            
            return depthFirstSearch(
                state: .init(timeRemaining: numberOfMinutes, robots: [.ore: 1], minerals: [:]),
                bestSoFar: 0
            )
        }
    }
}

fileprivate struct Blueprint {
    let id: Int
    let costsByRobot: [Mineral: [Mineral: Int]]
    
    func maxAmountNeededByMineral() -> [Mineral: Int] {
        let initial: [Mineral: Int] = [
            .ore: 0,
            .clay: 0,
            .obsidian: 0,
            .geode: .max
        ]
        return costsByRobot.values.reduce(into: initial, { maximums, cost in
            for (mineral, amount) in cost {
                maximums[mineral, default: 0] = max(maximums[mineral, default: 0], amount)
            }
        })
    }
    
    struct OreRobot: Robot {
        let ore: Int
        
        var cost: [Mineral: Int] { [.ore: ore] }
    }
    
    struct ClayRobot: Robot {
        let ore: Int
        
        var cost: [Mineral: Int] { [.ore: ore] }
    }
    
    struct ObsidianRobot: Robot {
        let ore: Int
        let clay: Int
        
        var cost: [Mineral: Int] {
            [.ore: ore, .clay: clay]
        }
    }
    
    struct GeodeRobot: Robot {
        let ore: Int
        let obsidian: Int
        
        var cost: [Mineral: Int] {
            [.ore: ore, .obsidian: obsidian]
        }
    }
}

fileprivate protocol Robot {
    var cost: [Mineral: Int] { get }
}

fileprivate extension Robot {
    func canBeBuilt(with minerals: [Mineral: Int]) -> Bool {
        cost.allSatisfy({ mineral, quantity in
            minerals[mineral, default: 0] >= quantity
        })
    }
}

fileprivate extension Blueprint {
    init?(rawValue: String) {
        let parts = rawValue.components(separatedBy: ": ")
        guard parts.count == 2 else {
            return nil
        }
        
        let leftWords = parts[0].components(separatedBy: " ")
        let rightSentences = parts[1].components(separatedBy: ". ")
        
        guard rightSentences.count == 4 else {
            return nil
        }
        
        guard let id = Int(leftWords[1]) else {
            return nil
        }
        
        guard let oreRobot = OreRobot(rawValue: rightSentences[0]) else {
            return nil
        }
        
        guard let clayRobot = ClayRobot(rawValue: rightSentences[1]) else {
            return nil
        }
        
        guard let obsidianRobot = ObsidianRobot(rawValue: rightSentences[2]) else {
            return nil
        }
        
        guard let geodeRobot = GeodeRobot(rawValue: rightSentences[3]) else {
            return nil
        }
        
        self.id = id
        self.costsByRobot = [
            .ore: oreRobot.cost,
            .clay: clayRobot.cost,
            .obsidian: obsidianRobot.cost,
            .geode: geodeRobot.cost,
        ]
    }
}

fileprivate extension Blueprint.OreRobot {
    init?(rawValue: String) {
        let words = rawValue.components(separatedBy: " ")
        guard words.count == 6 else {
            return nil
        }
        
        guard let ore = Int(words[4]) else {
            return nil
        }
        
        self.ore = ore
    }
}

fileprivate extension Blueprint.ClayRobot {
    init?(rawValue: String) {
        let words = rawValue.components(separatedBy: " ")
        guard words.count == 6 else {
            return nil
        }
        
        guard let ore = Int(words[4]) else {
            return nil
        }
        
        self.ore = ore
    }
}

fileprivate extension Blueprint.ObsidianRobot {
    init?(rawValue: String) {
        let words = rawValue.components(separatedBy: " ")
        guard words.count == 9 else {
            return nil
        }
        
        guard let ore = Int(words[4]) else {
            return nil
        }
        
        guard let clay = Int(words[7]) else {
            return nil
        }
        
        self.ore = ore
        self.clay = clay
    }
}

fileprivate extension Blueprint.GeodeRobot {
    init?(rawValue: String) {
        let words = rawValue.components(separatedBy: " ")
        guard words.count == 9 else {
            return nil
        }
        
        guard let ore = Int(words[4]) else {
            return nil
        }
        
        guard let obsidian = Int(words[7]) else {
            return nil
        }
        
        self.ore = ore
        self.obsidian = obsidian
    }
}

enum Mineral: Hashable {
    case ore
    case clay
    case obsidian
    case geode
}
