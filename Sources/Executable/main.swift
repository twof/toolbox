import Console
import Command
import VaporToolbox

let terminal = Terminal()

public struct VaporCommands: Group {
    public var commands: Group.Commands

    public var options: [Option]

    public var help: [String]

    public init() {
        self.commands = [
            "update": UpdateCommand()
        ]
        self.options = []
        self.help = []
    }

    public func run(using console: Console, with input: Input) throws {

    }
}

try terminal.run(VaporCommands(), arguments: CommandLine.arguments)
