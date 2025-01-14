import ActivityKit

public struct CricketActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var team1Score: String
        public var team2Score: String
        public var status: String
        
        public init(team1Score: String, team2Score: String, status: String) {
            self.team1Score = team1Score
            self.team2Score = team2Score
            self.status = status
        }
    }
    
    public var matchName: String
    public var team1Name: String
    public var team2Name: String
    
    public init(matchName: String, team1Name: String, team2Name: String) {
        self.matchName = matchName
        self.team1Name = team1Name
        self.team2Name = team2Name
    }
}

// End of file. No additional code.
