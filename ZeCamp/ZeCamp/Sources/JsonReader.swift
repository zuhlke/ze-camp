
import Foundation

class JsonReader{
    
    static func getJson<T: Decodable>(FileName fileName: String, type: T.Type) -> T {
        
        let eventURL = Bundle.main.bundleURL.appendingPathComponent("Content").appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: eventURL) else {
            fatalError()
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let schedule = try! decoder.decode(T.self, from: data)
        
        return schedule
    }
}
