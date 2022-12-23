//
//  Day21.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-21.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

extension Commands {
    struct Day21: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day21",
                abstract: "Solve day 21 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let jobsByMonkey: [String: MonkeyJob] = try readLines().reduce(into: [:], { result, line in
                guard let job = MonkeyJob(rawValue: line) else {
                    return
                }
                
                result[job.name] = job
            })
            
            printTitle("Part 1", level: .title1)
            let numberYelledByRootMonkey = part1(jobsByMonkey: jobsByMonkey)
            print(
                "What number will the monkey named root yell?",
                numberYelledByRootMonkey,
                terminator: "\n\n"
            )
            
            printTitle("Part 1", level: .title1)
            let numberWeShouldYell = part2(jobsByMonkey: jobsByMonkey)
            print(
                "What number do you yell to pass root's equality test?",
                numberWeShouldYell
            )
        }
        
        fileprivate func part1(jobsByMonkey: [String: MonkeyJob]) -> Int {
            value(for: jobsByMonkey["root"]!, in: jobsByMonkey)
        }
        
        fileprivate func part2(jobsByMonkey: [String: MonkeyJob]) -> Int {
            let jobForRoot = jobsByMonkey["root"]!
            
            guard case .mathOperation(_, let lhs, let rhs) = jobForRoot.action else {
                fatalError(#"Monket "root"'s job is not a math operation."#)
            }
            
            func depthFirstSearchPath(jobsByMonkey: [String: MonkeyJob], start: String, goal: String) -> [MonkeyJob] {
                struct State {
                    let job: MonkeyJob
                    let path: [MonkeyJob]
                }
                
                let startJob = jobsByMonkey[start]!
                var stack: Deque<State> = [.init(job: startJob, path: [startJob])]
                var visited = Set<MonkeyJob>()
                
                while let current = stack.popLast() {
                    guard !visited.contains(current.job) else {
                        continue
                    }
                    
                    if current.job.name == goal {
                        return current.path
                    }
                    
                    visited.insert(current.job)
                    
                    for neighbor in jobsByMonkey[current.job.name]!.action.dependencies {
                        let neighborJob = jobsByMonkey[neighbor]!
                        stack.append(.init(job: neighborJob, path: current.path + [neighborJob]))
                    }
                }
                
                fatalError(#"Could not find path from "\#(start)" to "\#(goal)""#)
            }
            
            let path = depthFirstSearchPath(jobsByMonkey: jobsByMonkey, start: "root", goal: "humn")
            let distinctJobsInPath = Set(path)
            
            func humanNumber(job: MonkeyJob, result: Int) -> Int {
                if job.name == "humn" {
                    return result
                }
                
                switch job.action {
                case .value:
                    fatalError("Could not find human number")
                    
                case .mathOperation(let operation, let lhs, let rhs):
                    let leftJob = jobsByMonkey[lhs]!
                    let rightJob = jobsByMonkey[rhs]!
                    if distinctJobsInPath.contains(leftJob) {
                        return humanNumber(
                            job: leftJob,
                            result: operation.invertLeft(
                                rhs: value(
                                    for: rightJob,
                                    in: jobsByMonkey
                                ),
                                result: result
                            )
                        )
                    }
                    else {
                        return humanNumber(
                            job: rightJob,
                            result: operation.invertRight(
                                lhs: value(
                                    for: leftJob,
                                    in: jobsByMonkey
                                ),
                                result: result
                            )
                        )
                    }
                }
            }
            
            let leftJob = jobsByMonkey[lhs]!
            let rightJob = jobsByMonkey[rhs]!
            if path.contains(leftJob) {
                let targetValue = value(for: rightJob, in: jobsByMonkey)
                return humanNumber(job: leftJob, result: targetValue)
            }
            else {
                let targetValue = value(for: jobsByMonkey[lhs]!, in: jobsByMonkey)
                return humanNumber(job: rightJob, result: targetValue)
            }
        }
        
        private func value(for monkeyJob: MonkeyJob, in jobsByMonkey: [String: MonkeyJob]) -> Int {
            switch monkeyJob.action {
            case .value(let value):
                return value
                
            case .mathOperation(let operation, let lhs, let rhs):
                return operation.calculate(
                    lhs: value(for: jobsByMonkey[lhs]!, in: jobsByMonkey),
                    rhs: value(for: jobsByMonkey[rhs]!, in: jobsByMonkey)
                )
            }
        }
    }
}

fileprivate struct MonkeyJob: Hashable {
    let name: String
    let action: Action
    
    func rotatedLeft() -> Self {
        switch action {
        case .value:
            return self
            
        case .mathOperation(let operation, let lhs, let rhs):
            switch operation {
            case .add:
                return Self(name: lhs, action: .mathOperation(operation: .subtract, lhs: name, rhs: rhs))
                
            case .subtract:
                return Self(name: lhs, action: .mathOperation(operation: .add, lhs: name, rhs: rhs))
                
            case .multiply:
                return Self(name: lhs, action: .mathOperation(operation: .divide, lhs: name, rhs: rhs))
                
            case .divide:
                return Self(name: lhs, action: .mathOperation(operation: .multiply, lhs: name, rhs: rhs))
            }
        }
    }
    
    func rotatedRight() -> Self {
        switch action {
        case .value:
            return self
            
        case .mathOperation(let operation, let lhs, let rhs):
            switch operation {
            case .add:
                return Self(name: rhs, action: .mathOperation(operation: .subtract, lhs: name, rhs: lhs))
                
            case .subtract:
                return Self(name: rhs, action: .mathOperation(operation: .subtract, lhs: lhs, rhs: name))
                
            case .multiply:
                return Self(name: rhs, action: .mathOperation(operation: .divide, lhs: name, rhs: lhs))
                
            case .divide:
                return Self(name: rhs, action: .mathOperation(operation: .divide, lhs: lhs, rhs: name))
            }
        }
    }
    
    enum Action: Hashable {
        case value(Int)
        case mathOperation(
            operation: MathOperation,
            lhs: String,
            rhs: String
        )
        
        init?(rawValue: String) {
            let components = rawValue.components(separatedBy: " ")
            
            if components.count == 1, let value = Int(components[0]) {
                self = .value(value)
                return
            }
            
            guard components.count == 3, let operation = MathOperation(rawValue: components[1]) else {
                return nil
            }
            
            self = .mathOperation(operation: operation, lhs: components[0], rhs: components[2])
        }
        
        var dependencies: Set<String> {
            switch self {
            case .mathOperation(_, let lhs, let rhs):
                return [lhs, rhs]
                
            case .value:
                return []
            }
        }
        
        var terms: Terms? {
            switch self {
            case .mathOperation(let operation, let lhs, let rhs):
                return (operation, lhs, rhs)
                
            case .value:
                return nil
            }
        }
    }
    
    typealias Terms = (operation: MathOperation, lhs: String, rhs: String)
    
    enum MathOperation: String, Hashable {
        case add = "+"
        case subtract = "-"
        case multiply = "*"
        case divide = "/"
        
        func calculate(lhs: Int, rhs: Int) -> Int {
            switch self {
            case .add:
                return lhs + rhs
                
            case .subtract:
                return lhs - rhs
            
            case .multiply:
                return lhs * rhs
                
            case .divide:
                return lhs / rhs
            }
        }
        
        func invertLeft(rhs: Int, result: Int) -> Int {
            switch self {
            case .add:
                return result - rhs
            
            case .subtract:
                return result + rhs
                
            case .multiply:
                return result / rhs
                
            case .divide:
                return result * rhs
            }
        }
        
        func invertRight(lhs: Int, result: Int) -> Int {
            switch self {
            case .add:
                return result - lhs
            
            case .subtract:
                return lhs - result
                
            case .multiply:
                return result / lhs
                
            case .divide:
                return lhs / result
            }
        }
    }
}

fileprivate extension MonkeyJob {
    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: ": ")
        guard components.count == 2, let action = Action(rawValue: components[1]) else {
            return nil
        }
        
        self.name = components[0]
        self.action = action
    }
}
