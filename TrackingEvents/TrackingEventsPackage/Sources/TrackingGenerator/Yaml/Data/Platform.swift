import Foundation

enum Platform: String, Codable, Hashable {
    case iOS = "ios"
    case android

    static let all: [Platform] = [.iOS, .android]
}
