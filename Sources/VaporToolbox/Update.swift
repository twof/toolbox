import Basic
import Console
import Command
import PackageGraph
import PackageLoading
import Foundation
import Workspace

/// Updates a Vapor Xcode Project after adding dependencies or changing file structure.
public final class UpdateCommand: Command {
    /// See Command.arguments
    public let arguments: [Argument]

    /// See Command.options
    public let options: [Option]

    /// See Command.help
    public var help: [String]

    /// Create a new Update Command.
    public init() {
        arguments = []
        options = [
            .init(name: "workDir", help: [
                "Override the working directory used for this command."
            ], default: nil)
        ]
        help = [
            "Updates a Vapor Xcode Project after adding dependencies or changing the file structure.",
            "Automatically fetches new or modified dependencies, re-generates, and opens .xcodeproj."
        ]
    }

    /// See Command.run
    public func run(using console: Console, with input: Input) throws {
        let workDir = input.options["workDir"].flatMap(AbsolutePath.init) ?? currentWorkingDirectory

        let manifestLoader = ManifestLoader(
            resources: self,
            isManifestSandboxEnabled: false
        )

        let workspace = Workspace(
            dataPath: workDir.appending(component: ".build"),
            editablesPath: workDir.appending(component: "Packages"),
            pinsFile: workDir.appending(component: "Package.resolved"),
            manifestLoader: manifestLoader,
            delegate: self
        )

        let packageRoot = PackageGraphRootInput(packages: [
            workDir
        ])

        let diagnostics = DiagnosticsEngine()
        workspace.updateDependencies(
            root: packageRoot,
            diagnostics: diagnostics
        )

        for diag in diagnostics.diagnostics {
            console.output("[ \(diag.behavior) ] ", style: diag.behavior.style, newLine: false)
            console.print(diag.localizedDescription)
        }
    }
}

extension Diagnostic.Behavior {
    var style: ConsoleStyle {
        switch self {
        case .error: return .error
        case .ignored: return .plain
        case .note: return .info
        case .warning: return .warning
        }
    }
}

extension UpdateCommand: WorkspaceDelegate {
    public func packageGraphWillLoad(currentGraph: PackageGraph, dependencies: AnySequence<ManagedDependency>, missingURLs: Set<String>) {
        print("\(#function)")
    }

    public func fetchingWillBegin(repository: String) {
        print("\(#function)")
    }

    public func fetchingDidFinish(repository: String, diagnostic: Diagnostic?) {
        print("\(#function)")
    }

    public func cloning(repository: String) {
        print("\(#function)")
    }

    public func removing(repository: String) {
        print("\(#function)")
    }

    public func managedDependenciesDidUpdate(_ dependencies: AnySequence<ManagedDependency>) {
        print("\(#function)")
    }


}

extension UpdateCommand: ManifestResourceProvider {
    public var swiftCompiler: AbsolutePath {
        return .init("/usr/bin/swift")
    }

    public var libDir: AbsolutePath {
        return .init("/usr/lib")
    }

    public var sdkRoot: AbsolutePath? {
        return .init("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk")
    }
}

/// The current working directory of the process (same as returned by POSIX' `getcwd()` function or Foundation's
/// `currentDirectoryPath` method).
/// FIXME: This should probably go onto `FileSystem`, under the assumption that each file system has its own notion of
/// the `current` working directory.
fileprivate var currentWorkingDirectory: AbsolutePath {
    let cwdStr = FileManager.default.currentDirectoryPath
    return AbsolutePath(cwdStr)
}
