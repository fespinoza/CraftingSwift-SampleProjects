import ArgumentParser
import Foundation

@main
struct TrackingGenerator: AsyncParsableCommand {
    @Option(help: "Path of the input file (optional), by default it will use the file in GitHub.")
    var inputFile: String?

    @Option(help: "If `inputFile` is not provided, it will use the latest commit of this branch")
    var branchName: String?

    @Option(help: "Output folder where the generated files will be set")
    var outputFolder: String = "../../TrackingEventsPackage/TrackingEvents/Sources/TrackingEvents/Generated"

    @Option(help: "To print the data we parsed from the YAML content")
    var debugYamlEvents: Bool = false

    func run() async throws {
        let input: TrackingEventScript.InputSource = if let inputFile {
            .fileUrl(URL(filePath: inputFile))
        } else {
            .github(branch: branchName ?? "main")
        }

        try await TrackingEventScript(
            inputSource: input,
            outputFolderUrl: URL(fileURLWithPath: outputFolder),
            debugYamlEvents: debugYamlEvents
        ).run()
    }
}
