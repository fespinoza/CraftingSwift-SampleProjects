import Foundation
import PathKit
import Stencil

struct SwiftCodeGenerator {
    let environment: Environment
    let locations: [LocationDefinition]
    let events: [EventDefinition]

    init(locations: [LocationDefinition], events: [EventDefinition]) {
        let templatesPath = Path(Bundle.module.resourcePath!)
        let loader = FileSystemLoader(paths: [templatesPath])
        let camelCaseExtension = Extension()
        camelCaseExtension.registerFilter("camelCase") { (value: Any?) in
            guard let string = value as? String else { return value }
            return string.snakeCaseToCamelCase()
        }

        self.environment = Environment(loader: loader, extensions: [camelCaseExtension])
        self.locations = locations
        self.events = events
    }

    func run(outputFolder: URL) throws {
        try write(
            generateLocationCode(),
            fileName: "TrackingLocation.swift",
            in: outputFolder
        )

        try write(
            generateEventCode(),
            fileName: "TrackingEvent-Values.swift",
            in: outputFolder
        )
    }

    func generateLocationCode() throws -> String {
        try environment.renderTemplate(
            name: "TrackingLocations_Template.stencil",
            context: ["locations": locations]
        )
    }

    func generateEventCode() throws -> String {
        try environment.renderTemplate(
            name: "TrackingEvent_Template.stencil",
            context: ["events": events]
        )
    }

    private func write(_ content: String, fileName: String, in outputFolder: URL) throws {
        try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)
        let outputFileURL = outputFolder.appendingPathComponent(fileName)
        try content.write(to: outputFileURL, atomically: true, encoding: .utf8)
    }
}
