import Foundation

struct DefinitionsContainer: Decodable, Hashable {
    let trackingLocations: [LocationDefinition]
    let trackingEvents: [EventDefinition]

    enum CodingKeys: String, CodingKey {
        case trackingLocations = "tracking_locations"
        case trackingEvents = "tracking_events"
    }

    var iOSLocations: [LocationDefinition] {
        trackingLocations.filter { $0.platforms.contains(.iOS) }
    }

    var iOSEvents: [EventDefinition] {
        trackingEvents.filter { $0.platforms.contains(.iOS) }
    }
}
