import Foundation
import Stencil

struct LocationDefinition: Hashable {
    let id: String
    let platforms: [Platform]
    let description: String?

    var isNameSameAsId: Bool { id == id.snakeCaseToCamelCase() }
    var name: String { id.snakeCaseToCamelCase() }

    init(id: String, platforms: [Platform] = Platform.all, description: String? = nil) {
        self.id = id
        self.platforms = platforms
        self.description = description
    }
}

extension LocationDefinition: DynamicMemberLookup {
    /// I needed to do this for the computed variables to be visible to Stencil
    subscript(dynamicMember member: String) -> Any? {
        switch member {
        case "id": id
        case "description": description
        case "isNameSameAsId": isNameSameAsId
        case "name": name
        default: nil
        }
    }
}

extension LocationDefinition: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case platforms
        case description
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.platforms = (try? container.decode([Platform].self, forKey: .platforms)) ?? Platform.all
        self.description = try? container.decode(String.self, forKey: .description)
    }
}

extension String {
    func snakeCaseToCamelCase() -> String {
        let parts = split(separator: "_")
        guard let first = parts.first?.lowercased() else { return self }

        let rest = parts.dropFirst().map { part in
            part.capitalized
        }

        return ([first] + rest).joined()
    }
}
