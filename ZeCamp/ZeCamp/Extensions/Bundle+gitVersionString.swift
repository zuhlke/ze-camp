import Foundation

extension Bundle {
    var gitVersionString: String? {
        guard let gitCommit = self.infoDictionary?["GIT_COMMIT"] as? String,
              let gitStatus = self.infoDictionary?["GIT_STATUS"] as? String else {
                return nil
        }
        
        return "\(gitCommit) (\(gitStatus))"
    }
    
    var buddybuildBuildNumber: Int? {
        return self.infoDictionary?["BUDDYBUILD_BUILD_NUMBER"] as? Int
    }
}
