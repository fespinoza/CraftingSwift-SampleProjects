import Foundation

struct TrackingEventScript {
    enum InputSource {
        case github(branch: String)
        case fileUrl(URL)
    }

    let inputSource: InputSource
    let outputFolderUrl: URL
    /// controls if we want to print the parsed yaml events
    let debugYamlEvents: Bool

    func run() async throws {
        let eventsData = try await fetchData()

        print("--- extracting definitions")
        let definitions = try YamlLoader().decode(data: eventsData)
        printContents(for: definitions)

        print("--- generating code")
        try SwiftCodeGenerator(
            locations: definitions.iOSLocations,
            events: definitions.iOSEvents
        ).run(outputFolder: outputFolderUrl)
    }

    private func fetchData() async throws -> Data {
        switch inputSource {
        case let .github(branch):
            print("--- fetching GitHub data")
            return try await GitHubFileFetcher().fetchEventsContent(branch: branch)

        case let .fileUrl(url):
            print("--- loading data from file at \(url)")
            return try Data(contentsOf: url)
        }
    }

    private func printContents(for container: DefinitionsContainer) {
        guard debugYamlEvents else { return }

        print("--- \(container.trackingLocations.count) locations")
        container.trackingLocations.forEach { print($0) }

        print("--- \(container.trackingEvents.count) events")
        container.trackingEvents.forEach { print($0) }

        print("\n\n")
    }
}
