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
                let components = line.components(separatedBy: ": ")
                guard components.count == 2, let job = MonkeyJob(rawValue: components[1]) else {
                    return
                }
                
                result[components[0]] = job
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
            value(forMonkey: "root", in: jobsByMonkey)
        }
        
        fileprivate func part2(jobsByMonkey: [String: MonkeyJob]) -> Int {
            var jobsByMonkey = jobsByMonkey
            jobsByMonkey.removeValue(forKey: "humn")
            let jobForRoot = jobsByMonkey["root"]!
            
            guard case .mathOperation(_, let lhs, let rhs) = jobForRoot else {
                fatalError(#"Monket "root"'s job is not a math operation."#)
            }
            
            let lhsDependencies = dependencies(forMonkey: lhs, in: jobsByMonkey)
            
            let monkeyDependingOnHuman: String
            let valueOfOtherMonkey: Int
            if lhsDependencies.contains("humn") {
                monkeyDependingOnHuman = lhs
                valueOfOtherMonkey = value(forMonkey: rhs, in: jobsByMonkey)
            }
            else {
                monkeyDependingOnHuman = rhs
                valueOfOtherMonkey = value(forMonkey: lhs, in: jobsByMonkey)
            }
            
            var monkeyJobsInRelationToHuman: [String: MonkeyJob] = [monkeyDependingOnHuman: .value(valueOfOtherMonkey)]
            var queue: Deque = [monkeyDependingOnHuman, "humn"]
            var visited = Set<String>()
            
            while let current = queue.popFirst() {
                if visited.contains(current) {
                    continue
                }
                visited.insert(current)
                
                if let job = jobsByMonkey[current], case .value = job {
                    monkeyJobsInRelationToHuman[current] = job
                    continue
                }
                
                let pairsDependingOnCurrent = jobsByMonkey.filter({ $1.dependencies.contains(current) })
                for pairDependingOnCurrent in pairsDependingOnCurrent {
                    let terms = pairDependingOnCurrent.value.terms!
                    let correctedTerms = termsOfOperation(
                        terms.operation,
                        result: pairDependingOnCurrent.key,
                        lhs: terms.lhs,
                        rhs: terms.rhs,
                        inRelationTo: current
                    )
                    let job: MonkeyJob = .mathOperation(
                        operation: correctedTerms.operation,
                        lhs: correctedTerms.lhs,
                        rhs: correctedTerms.rhs
                    )
                    monkeyJobsInRelationToHuman[current] = job
                    
                    let nextInQueue = job.dependencies.filter({ !visited.contains($0) })
                    queue.append(contentsOf: nextInQueue)
                }
            }
            
            return value(forMonkey: "humn", in: monkeyJobsInRelationToHuman)
        }
        
        private func value(forMonkey target: String, in jobsByMonkey: [String: MonkeyJob]) -> Int {
            var monkeysToConfirm = dependencies(forMonkey: target, in: jobsByMonkey).union([target])
            var confirmedValuesByMonkey = [String: Int]()
            
            while !monkeysToConfirm.isEmpty {
                for monkey in monkeysToConfirm {
                    let isValueConfirmed: Bool
                    switch jobsByMonkey[monkey] {
                    case .value(let value):
                        confirmedValuesByMonkey[monkey] = value
                        isValueConfirmed = true
                        
                    case .mathOperation(let operation, let lhsMonkey, let rhsMonkey):
                        if let lhs = confirmedValuesByMonkey[lhsMonkey], let rhs = confirmedValuesByMonkey[rhsMonkey] {
                            let value = operation.calculate(lhs: lhs, rhs: rhs)
                            confirmedValuesByMonkey[monkey] = value
                            isValueConfirmed = true
                        }
                        else {
                            isValueConfirmed = false
                        }
                        
                    case nil:
                        continue
                    }
                    
                    if isValueConfirmed {
                        monkeysToConfirm.remove(monkey)
                    }
                }
            }
            
            return confirmedValuesByMonkey[target]!
        }
        
        private func dependencies(forMonkey target: String, in jobsByMonkey: [String: MonkeyJob]) -> Set<String> {
            guard let jobForTarget = jobsByMonkey[target] else {
                return []
            }
            
            var dependencies = Set<String>()
            var queue = Deque<String>()
            switch jobForTarget {
            case .mathOperation:
                queue.append(contentsOf: jobForTarget.dependencies)
                
            case .value:
                return []
            }
            
            while let current = queue.popFirst() {
                dependencies.insert(current)
                
                if let currentJob = jobsByMonkey[current] {
                    let nextInQueue = currentJob.dependencies.filter({ !dependencies.contains($0) })
                    queue.append(contentsOf: nextInQueue)
                }
            }
            
            return dependencies
        }
        
        private func termsOfOperation(
            _ operation: MonkeyJob.MathOperation,
            result: String,
            lhs: String,
            rhs: String,
            inRelationTo targetMonkey: String
        ) -> MonkeyJob.Terms {
            if targetMonkey == result {
                return (operation, lhs, rhs)
            }
            
            switch operation {
            case .add:
                if targetMonkey == lhs {
                    return (.subtract, result, rhs)
                }
                else {
                    return (.subtract, result, lhs)
                }
                
            case .subtract:
                if targetMonkey == lhs {
                    return (.add, result, rhs)
                }
                else {
                    return (.subtract, lhs, result)
                }
                
            case .multiply:
                if targetMonkey == lhs {
                    return (.divide, result, rhs)
                }
                else {
                    return (.divide, result, lhs)
                }
                
            case .divide:
                if targetMonkey == lhs {
                    return (.multiply, result, rhs)
                }
                else {
                    return (.divide, lhs, result)
                }
            }
        }
    }
}

fileprivate enum MonkeyJob {
    case value(Int)
    case mathOperation(
        operation: MathOperation,
        lhs: String,
        rhs: String
    )
    
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
    
    typealias Terms = (operation: MathOperation, lhs: String, rhs: String)
    
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
    
    enum MathOperation: String {
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
    }
}
