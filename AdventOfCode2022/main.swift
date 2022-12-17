//
//  main.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-01.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

enum Commands {
    struct MainCommand: ParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "aoc2022",
                abstract: "A program to solve Advent of Code 2022 puzzles",
                version: "0.0.1",
                subcommands: [
                    Commands.Day1.self,
                    Commands.Day2.self,
                    Commands.Day3.self,
                    Commands.Day4.self,
                    Commands.Day5.self,
                    Commands.Day6.self,
                    Commands.Day7.self,
                    Commands.Day8.self,
                    Commands.Day9.self,
                    Commands.Day10.self,
                    Commands.Day11.self,
                    Commands.Day12.self,
                    Commands.Day13.self,
                    Commands.Day14.self,
                    Commands.Day15.self,
                    Commands.Day16.self,
                ]
            )
        }
    }
}

Commands.MainCommand.main()
