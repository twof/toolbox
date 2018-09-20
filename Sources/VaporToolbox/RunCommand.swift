import Basic
import Build
import Utility
import PackageModel
import PackageGraph
import PackageLoading
import SourceControl
import Vapor
import Workspace
import Xcodeproj

func pepper<T>(_ thing: T, line: Int = #line) {
    print("[\(line)] \(thing)")
}

/// Generates an Xcode project for SPM packages.
struct RunCommand: Command {
    /// See `Command`.
    var arguments: [CommandArgument] = []

    /// See `Command`.
    var options: [CommandOption] = []

    /// See `Command`.
    var help: [String] = ["Generates Xcode projects for SPM packages."]

    /// See `Command`.
    func run(using ctx: CommandContext) throws -> Future<Void> {
        ctx.console.output("Loading package graph...")
        let rootPath: AbsolutePath = "/Users/loganwright/Desktop/test"
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw ToolboxError("Unknown current working directory")
        }
        let manifestLoader = ManifestLoader(
            resources: BasicManifestResourceProvider(
                swiftCompiler: "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc",
                libDir: "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/pm"
            ),
            isManifestCachingEnabled: true
        )
        let provider = GitRepositoryProvider(processSet: ProcessSet())
        let workspace = Workspace(
            dataPath: rootPath.appending(component: ".build"),
            editablesPath: rootPath.appending(component: "Packages"),
            pinsFile: rootPath.appending(component: "Package.resolved"),
            manifestLoader: manifestLoader,
            toolsVersionLoader: ToolsVersionLoader(),
            delegate: ConsoleWorkspaceDelegate(console: ctx.console),
            repositoryProvider: provider,
            isResolverPrefetchingEnabled: true,
            skipUpdate: false
        )
        let rootInput = PackageGraphRootInput(packages: [rootPath])
        let engine = DiagnosticsEngine()
        let graph = workspace.loadPackageGraph(root: rootInput, diagnostics: engine)
        // TODO: !
        let rootTargets = graph.rootPackages.flatMap { $0.products }
        let _ = rootTargets.filter { $0.type == .executable }

//        let targets = root.targets
//        let options = XcodeprojOptions()
        pepper("")
//        let destination = try Destination.hostDestination()//originalWorkingDirectory: cwd)
        let destination = try Destination.hostDestination("/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/")
        pepper("\(destination)")
        let toolchain = try UserToolchain(destination: destination)
        pepper("\(toolchain)")
        let triple = try Triple(toolchain.destination.target)
        pepper("\(triple)")
        let params = BuildParameters.init(
            dataPath: rootPath.appending(component: toolchain.destination.target),
            configuration: .debug,
            toolchain: toolchain,
            destinationTriple: triple, // default, can remove
            flags: BuildFlags(),
            toolsVersion: ToolsVersion.currentToolsVersion, // default, can remove (all below)
            shouldLinkStaticSwiftStdlib: false,
            shouldEnableManifestCaching: false,
            sanitizers: EnabledSanitizers()
        )
        let plan = try BuildPlan.init(buildParameters: params, graph: graph, diagnostics: engine)
        print("\n\n\n********\n\n\n")
        print(plan.graph)
        print("\n\n\n********\n\n\n")
        print(graph.rootPackages)
        print("\n\n\n********\n\n\n")
//
//        guard !graph.rootPackages.isEmpty else {
//            engine.diagnostics.forEach { ctx.console.diagnostic($0) }
//            throw VaporError(identifier: "noRootPackage", reason: "No root package found.")
//        }
//        let name = graph.rootPackages[0].name
//        let xcodeprojPath = rootPath.appending(component: name + ".xcodeproj")
//        ctx.console.output("Generating Xcode project for " + name.consoleText(.info) + "...")
//        try generate(projectName: name, xcodeprojPath: xcodeprojPath, graph: graph, options: options, diagnostics: engine)
//        let prettyPath = xcodeprojPath.prettyPath(cwd: rootPath)
//
//        engine.diagnostics.forEach { ctx.console.diagnostic($0) }
//        if ctx.console.confirm("Open " + prettyPath.consoleText(color: .magenta) + "?") {
//            _ = try Process.execute("open", xcodeprojPath.asString)
//        }
        return .done(on: ctx.container)
    }
}
