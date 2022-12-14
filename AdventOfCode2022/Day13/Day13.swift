//
//  Day13.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-13.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day13: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day13",
                abstract: "Solve day 13 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let decoder = JSONDecoder()
            let pairs: [(left: [ListItem], right: [ListItem])] = try readFile()
                .components(separatedBy: "\n\n")
                .compactMap({ pair in
                    let elements = pair.components(separatedBy: .newlines)
                    
                    guard elements.count == 2 else {
                        return nil
                    }
                    
                    let left = try decoder.decode([ListItem].self, from: Data(elements[0].utf8))
                    let right = try decoder.decode([ListItem].self, from: Data(elements[1].utf8))
                    
                    return (left, right)
                })
            
            let sumOfIndicesOfPairsInRightOrder = part1(pairs: pairs)
            printTitle("Part 1", level: .title1)
            print(
                "Determine which pairs of packets are already in the right order. What is the sum of the indices of those pairs?",
                sumOfIndicesOfPairsInRightOrder,
                terminator: "\n\n"
            )
            
            let decoderKey = part2(pairs: pairs)
            printTitle("Part 2", level: .title1)
            print(
                "Organize all of the packets into the correct order. What is the decoder key for the distress signal?",
                decoderKey
            )
        }
        
        fileprivate func part1(pairs: [(left: [ListItem], right: [ListItem])]) -> Int {
            let indicesInRightOrder = pairs.indices.filter({ index in
                areInRightOrder(pairs[index].left, pairs[index].right) == true
            })
            
            return indicesInRightOrder.reduce(into: 0, { sum, index in
                sum += index + 1
            })
        }
        
        fileprivate func part2(pairs: [(left: [ListItem], right: [ListItem])]) -> Int {
            var packets: [[ListItem]] = pairs.reduce(into: [], { result, pair in
                result.append(pair.left)
                result.append(pair.right)
            })
            
            let decoderPackets: [[ListItem]] = [
                [.list([.integer(2)])],
                [.list([.integer(6)])]
            ]
            packets.append(contentsOf: decoderPackets)
            
            let sortedPackets = packets.sorted(by: { areInRightOrder($0, $1) ?? false })
            return decoderPackets.reduce(into: 1, { product, packet in
                guard let index = sortedPackets.firstIndex(of: packet) else {
                    return
                }
                
                product *= index + 1
            })
        }
    }
}

fileprivate func areInRightOrder(_ left: [ListItem], _ right: [ListItem]) -> Bool? {
    areInRightOrder(.list(left), .list(right))
}

fileprivate func areInRightOrder(_ left: ListItem, _ right: ListItem) -> Bool? {
    switch (left, right) {
    case (.integer(let leftValue), .integer(let rightValue)):
        if leftValue < rightValue {
            return true
        }
        if leftValue > rightValue {
            return false
        }
        if leftValue == rightValue {
            return nil
        }
        
    case (.list(let left), .list(let right)):
        var leftHasRunOut = false
        var rightHasRunOut = false
        for index in 0... {
            leftHasRunOut = index == left.endIndex
            rightHasRunOut = index == right.endIndex
            
            if leftHasRunOut, rightHasRunOut {
                return nil
            }
            
            if leftHasRunOut {
                return true
            }
            
            if rightHasRunOut {
                return false
            }
            
            if let areInRightOrder = areInRightOrder(left[index], right[index]) {
                return areInRightOrder
            }
        }
        
        return nil
        
    case (.integer(let left), .list):
        return areInRightOrder(.list([.integer(left)]), right)
        
    case (.list, .integer(let right)):
        return areInRightOrder(left, .list([.integer(right)]))
    }
    
    return nil
}

fileprivate indirect enum ListItem: Equatable {
    case integer(Int)
    case list([ListItem])
}

extension ListItem: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Int.self) {
            self = .integer(value)
            return
        }
        
        if let list = try? container.decode([ListItem].self) {
            self = .list(list)
            return
        }
        
        throw DecodingError.dataCorrupted(.init(
            codingPath: container.codingPath,
            debugDescription: "Item is neither an integer nor a list."
        ))
    }
}
