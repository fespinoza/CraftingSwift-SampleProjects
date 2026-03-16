import Foundation
import Yams

struct YamlLoader {
    func loadDefinitions(from inputFileUrl: URL) throws -> DefinitionsContainer {
        let data = try Data(contentsOf: inputFileUrl)
        return try decode(data: data)
    }

    func decode(data: Data) throws -> DefinitionsContainer {
        let decoder = YAMLDecoder()
        return try decoder.decode(DefinitionsContainer.self, from: data)
    }

    func dumpYamlData(from inputFileUrl: URL) throws {
        let data = try Data(contentsOf: inputFileUrl)
        let string = String(data: data, encoding: .utf8)!

        let yamlContent = try Yams.load(yaml: string) as? [String: Any]
        dump(yamlContent)
    }
}
