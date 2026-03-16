import Foundation

public struct TrackingEvent: Hashable, Sendable {
    public let eventName: String
    public let parameters: [String: String]

    init(event: String, location: TrackingLocation, parameters: [String: String] = [:]) {
        assert(
            event.count <= 40,
            "❌ Event and parameter names cannot exceed 40 characters '\(event)' (\(event.count) characters)\n" +
                "https://support.google.com/firebase/answer/9237506?hl=en"
        )

        self.eventName = event
        var eventParameters: [String: String] = parameters
        eventParameters["location"] = location.rawValue
        self.parameters = eventParameters
    }
}
