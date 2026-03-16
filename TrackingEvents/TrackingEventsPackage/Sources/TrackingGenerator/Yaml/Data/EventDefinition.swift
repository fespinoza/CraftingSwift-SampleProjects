import Foundation

struct EventDefinition: Decodable, Hashable {
    let name: String
    let parameters: [String]
    let platforms: [Platform]
    let description: String?
    let defaultLocation: LocationDefinition?

    enum CodingKeys: String, CodingKey {
        case name
        case parameters
        case platforms
        case description
        case defaultLocation = "default_location"
    }

    init(
        name: String,
        parameters: [String] = [],
        platforms: [Platform] = Platform.all,
        description: String? = nil,
        defaultLocation: LocationDefinition? = nil
    ) {
        self.name = name
        self.parameters = parameters
        self.platforms = platforms
        self.description = description
        self.defaultLocation = defaultLocation
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.parameters = (try? container.decode([String].self, forKey: .parameters)) ?? []
        self.platforms = (try? container.decode([Platform].self, forKey: .platforms)) ?? Platform.all
        self.description = try? container.decode(String.self, forKey: .description)
        self.defaultLocation = try? container.decodeIfPresent(LocationDefinition.self, forKey: .defaultLocation)
    }

    var camelCaseName: String {
        name.snakeCaseToCamelCase()
    }
}
