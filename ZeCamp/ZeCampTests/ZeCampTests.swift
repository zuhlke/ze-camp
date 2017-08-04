import XCTest
@testable import ZeCamp

class ZeCampTests: XCTestCase {
    
    #if SIMULATOR
    func testThatProjectFileHasNoEmbeddedBuildConfigurations() {
        guard let projectFilePath = Bundle(for: ZeCampTests.self).infoDictionary?["projectFilePath"] as? String else {
            XCTFail("The project file path should be specified in the info.plist file.")
            return
        }
        
        let url = URL(fileURLWithPath: "\(projectFilePath)/project.pbxproj")
        
        guard let project = try? String(contentsOf: url) else {
            XCTFail("Failed to read project file. Maybe path is incorrect or we don’t have permission.")
            return
        }
        
        if let range = project.range(of: "buildSettings\\s*=\\s*\\{[^\\}]*?=[^\\}]*?\\}", options: .regularExpression) {
            let buildSettings = project.substring(with: range)
            .replacingOccurrences(of: "\n", with: " ")
            XCTFail("There should be no build settings in the project file. Please move all settings to .xcconfig files. Found: \(buildSettings)")
        }
    }
    #endif

}
