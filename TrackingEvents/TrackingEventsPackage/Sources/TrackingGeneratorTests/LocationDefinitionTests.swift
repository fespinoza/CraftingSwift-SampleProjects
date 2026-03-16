import Testing
@testable import TrackingGenerator

enum LocationDefinitionTests {
    @Suite("isNameSameAsId")
    struct IsNameSameAsIdTests {
        @Test func `true, when the id is the same as the camel case name`() {
            let location = LocationDefinition(id: "activity")
            #expect(
                location.isNameSameAsId,
                "'activity' doesn't have a snake case on it \(location.id) - \(location.name)"
            )
        }

        @Test func `false, when the id has snake case elements on it`() {
            let location = LocationDefinition(id: "check_in_intent")
            #expect(
                !location.isNameSameAsId,
                "'check_in_intent' should have name `checkInIntent` '\(location.id)' - '\(location.name)'"
            )
        }
    }
}
