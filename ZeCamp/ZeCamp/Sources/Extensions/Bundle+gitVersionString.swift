import Foundation

extension Bundle {
    var commitId: String? {
        guard
            let gitCommit = self.infoDictionary?["GIT_COMMIT"] as? String,
            let gitStatus = self.infoDictionary?["GIT_STATUS"] as? String else {
                return nil
        }
        
        return "\(gitCommit) (\(gitStatus))"
    }
    
    var shortCommitId: String? {
        return commitId.map {
            return String($0.prefix(8))
        }
    }

    var buddybuildBuildNumber: Int? {
        return self.infoDictionary?["BUDDYBUILD_BUILD_NUMBER"] as? Int
    }
}
