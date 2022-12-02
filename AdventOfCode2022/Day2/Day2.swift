//
//  Day2.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-01.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day2: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day2",
                abstract: "Solve day 2 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let input: [(String, String)] = try readLines()
                .map({ line in
                    let moves = line.components(separatedBy: " ")
                    return (moves[0], moves[1])
                })
            
            let totalScoreAccordingToIncompleteGuide = part1(input: input)
            printTitle("Part 1", level: .title1)
            print(
                "Total score if everything goes according to the incomplete strategy guide:",
                totalScoreAccordingToIncompleteGuide,
                terminator: "\n\n"
            )
            
            let totalScoreAccordingToCompleteGuide = part2(input: input)
            printTitle("Part 2", level: .title1)
            print(
                "Total score if everything goes according to the complete strategy guide:",
                totalScoreAccordingToCompleteGuide,
                terminator: "\n\n"
            )
        }
        
        func part1(input: [(String, String)]) -> Int {
            let moves: [(RockPaperScissors.Move, RockPaperScissors.Move)] = input.map({ pair in
                let opponentMove = RockPaperScissors.Move(opponentMove: pair.0)!
                let ownMove = RockPaperScissors.Move(ownMove: pair.1)!
                return (opponentMove, ownMove)
            })
            
            return moves.reduce(into: 0, { score, pair in
                let (opponentMove, ownMove) = pair
                let outcome = RockPaperScissors.Outcome(opponentMove: opponentMove, ownMove: ownMove)
                score += outcome.score + ownMove.score
            })
        }
        
        func part2(input: [(String, String)]) -> Int {
            let moveOutcomePairs: [(RockPaperScissors.Move, RockPaperScissors.Outcome)] = input.map({ pair in
                let opponentMove = RockPaperScissors.Move(opponentMove: pair.0)!
                let outcome = RockPaperScissors.Outcome(rawValue: pair.1)!
                return (opponentMove, outcome)
            })
            
            return moveOutcomePairs.reduce(into: 0, { score, pair in
                let (opponentMove, desiredOutcome) = pair
                let ownMove = desiredOutcome.ownMove(forOpponentMove: opponentMove)
                score += desiredOutcome.score + ownMove.score
            })
        }
    }
}

enum RockPaperScissors {
    enum Move {
        case rock
        case paper
        case scissors
        
        init?(opponentMove: String) {
            switch opponentMove {
            case "A":
                self = .rock
                
            case "B":
                self = .paper
                
            case "C":
                self = .scissors
                
            default:
                return nil
            }
        }
        
        init?(ownMove: String) {
            switch ownMove {
            case "X":
                self = .rock
                
            case "Y":
                self = .paper
                
            case "Z":
                self = .scissors
                
            default:
                return nil
            }
        }
        
        var score: Int {
            switch self {
            case .rock:
                return 1
                
            case .paper:
                return 2
                
            case .scissors:
                return 3
            }
        }
    }
    
    enum Outcome {
        case loss
        case draw
        case win
        
        init?(rawValue: String) {
            switch rawValue {
            case "X":
                self = .loss
                
            case "Y":
                self = .draw
                
            case "Z":
                self = .win
                
            default:
                return nil
            }
        }
        
        init(opponentMove: Move, ownMove: Move) {
            switch (opponentMove, ownMove) {
            case (.rock, .rock),
                (.paper, .paper),
                (.scissors, .scissors):
                self = .draw
                
            case (.rock, .scissors),
                (.paper, .rock),
                (.scissors, .paper):
                self = .loss
                
            case (.rock, .paper),
                (.paper, .scissors),
                (.scissors, .rock):
                self = .win
            }
        }
        
        func ownMove(forOpponentMove opponentMove: Move) -> Move {
            switch (self, opponentMove) {
            case (.draw, _):
                return opponentMove
                
            case (.loss, .rock):
                return .scissors
                
            case (.loss, .paper):
                return .rock
                
            case (.loss, .scissors):
                return .paper
                
            case (.win, .rock):
                return .paper
            
            case (.win, .paper):
                return .scissors
                
            case (.win, .scissors):
                return .rock
            }
        }
        
        var score: Int {
            switch self {
            case .loss:
                return 0
                
            case .draw:
                return 3
                
            case .win:
                return 6
            }
        }
    }
}
