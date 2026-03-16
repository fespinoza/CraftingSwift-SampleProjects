import CustomDump
import Foundation
import Testing
@testable import TrackingGenerator

@Suite("YamlLoader")
struct YamlLoaderTests {
    @Suite("Locations")
    struct Locations {
        @Test func `decodes YAML tracking locations`() throws {
            let content = """
            tracking_locations:
              - &activity
                id: activity
              - &check_in_intent
                id: check_in_intent
                platforms:
                  - ios
                description: "Specific App Intent for iOS"
              - id: calendar_settings
                platforms:
                    - android
              - id: not_applicable
                description: It's a generic location to indicate NO location
            tracking_events:
                - name: sign_in
            """
            let yamlData = try #require(content.data(using: .utf8))

            let container = try YamlLoader().decode(data: yamlData)

            // Basic decoding
            #expect(container.trackingLocations.count == 4)
            #expect(container.iOSLocations.count == 3)

            expectNoDifference(
                container.iOSLocations,
                [
                    .init(id: "activity"),
                    .init(
                        id: "check_in_intent",
                        platforms: [.iOS],
                        description: "Specific App Intent for iOS"
                    ),
                    .init(
                        id: "not_applicable",
                        description: "It's a generic location to indicate NO location"
                    ),
                ]
            )
        }
    }

    @Suite("Events")
    struct Events {
        @Test func `decode a simple event`() throws {
            let content = """
            tracking_locations:
                - id: activity
            tracking_events:
                - name: sign_in
            """
            let yamlData = try #require(content.data(using: .utf8))

            let container = try YamlLoader().decode(data: yamlData)

            expectNoDifference(container.iOSEvents, [.init(name: "sign_in")])
        }

        @Test func `decode and event with parameters and default location`() throws {
            let content = """
            tracking_locations:
                - &activity
                    id: activity
            tracking_events:
                - name: join_challenge
                  default_location: *activity
                  parameters:
                    - challenge_id
            """
            let yamlData = try #require(content.data(using: .utf8))

            let container = try YamlLoader().decode(data: yamlData)

            expectNoDifference(
                container.iOSEvents,
                [
                    .init(
                        name: "join_challenge",
                        parameters: ["challenge_id"],
                        defaultLocation: .init(id: "activity")
                    ),
                ]
            )
        }

        @Test func `filter out android events + gets descriptions`() throws {
            let content = """
            tracking_locations:
                - &activity
                    id: activity
            tracking_events:
              - name: test_event
                description: Sometimes we describe more about events
                platforms:
                  - ios
              - name: test_event_with_params # comment
                platforms:
                  - android
                parameters:
                  - is_this_true
            """
            let yamlData = try #require(content.data(using: .utf8))

            let container = try YamlLoader().decode(data: yamlData)

            expectNoDifference(
                container.iOSEvents,
                [
                    .init(
                        name: "test_event",
                        platforms: [.iOS],
                        description: "Sometimes we describe more about events"
                    ),
                ]
            )
        }
    }
}
