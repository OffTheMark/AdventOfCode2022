//
//  Day7.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-06.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import SwiftDataStructures

extension Commands {
    struct Day7: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day7",
                abstract: "Solve day 7 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let tree = parse(input: try readLines())
            
            let sumOfDirectorySizes = part1(tree: tree)
            printTitle("Title 1", level: .title1)
            print(
                "What is the sum of the total sizes of directories with a total size of at most 100000?",
                sumOfDirectorySizes,
                terminator: "\n\n"
            )
        }
        
        private func parse(input: [String]) -> TreeNode<FileNode> {
            let root = TreeNode<FileNode>(value: .directory(name: "/"))
            var nodesByDirectory = [String: TreeNode<FileNode>]()
            nodesByDirectory[root.path] = root
            
            var currentNode = root
            for line in input {
                switch Command(rawValue: line) {
                case .changeDirectory(let target):
                    switch target {
                    case "..":
                        currentNode = currentNode.parent!
                        continue
                        
                    case "/":
                        currentNode = root
                        continue
                    
                    default:
                        currentNode = currentNode.children.first(where: { child in
                            switch child.value {
                            case .directory(let name):
                                return name == target
                                
                            case .file:
                                return false
                            }
                        })!
                        continue
                    }
                    
                case .list:
                    continue
                    
                default:
                    break
                }
                
                guard let fileNode = FileNode(rawValue: line) else {
                    continue
                }
                
                let node = TreeNode<FileNode>(value: fileNode)
                currentNode.addChild(node)
                
                switch fileNode {
                case .file:
                    break
                    
                case .directory:
                    nodesByDirectory[node.path] = node
                }
            }
            
            return root
        }
        
        func part1(tree: TreeNode<FileNode>) -> Int {
            var sizeByDirectory = [String: Int]()
            
            func size(of node: TreeNode<FileNode>) -> Int {
                switch node.value {
                case .directory:
                    if let size = sizeByDirectory[node.path] {
                        return size
                    }
                    
                    let size = node.children.reduce(into: 0, { result, child in
                        result += size(of: child)
                    })
                    sizeByDirectory[node.path] = size
                    return size
                    
                case .file(let size, _):
                    return size
                }
            }
            
            tree.recursiveForEach({ _ = size(of: $0) })
            
            let directoriesWithSizeAtMost100000 = sizeByDirectory.filter({ _, size in
                size <= 100_000
            })
            return directoriesWithSizeAtMost100000.reduce(into: 0, { result, pair in
                let (_, size) = pair
                result += size
            })
        }
        
        enum FileNode: Equatable {
            case directory(name: String)
            case file(size: Int, name: String)
            
            init?(rawValue: String) {
                let components = rawValue.components(separatedBy: " ")
                guard components.count == 2 else {
                    return nil
                }
                
                if components[0] == "dir" {
                    self = .directory(name: components[1])
                    return
                }
                
                if let size = Int(components[0]) {
                    self = .file(size: size, name: components[1])
                    return
                }
                
                return nil
            }
            
            var name: String {
                switch self {
                case .directory(let name):
                    return name
                    
                case .file(_, let name):
                    return name
                }
            }
        }
        
        enum Command {
            case changeDirectory(target: String)
            case list
            
            init?(rawValue: String) {
                let parts = rawValue.components(separatedBy: " ")
                
                guard parts.first == "$" else {
                    return nil
                }
                
                if parts.count == 2, parts[1] == "ls" {
                    self = .list
                    return
                }
                
                if parts.count == 3, parts[1] == "cd" {
                    self = .changeDirectory(target: parts[2])
                    return
                }
                
                return nil
            }
        }
    }
}

extension TreeNode where Element == Commands.Day7.FileNode {
    var path: String {
        var parts = Array(ancestors.reversed())
        parts.append(self)
        
        return parts
            .map({ $0.value.name })
            .joined(separator: "/")
    }
}
