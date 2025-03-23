import ActivityKit
import Foundation

public struct CricketActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var team1Score: String
        public var team2Score: String
        public var status: String
        public var currentBatsmen: String
        public var lastBowling: String
        public var currentOver: Double
        public var recentDeliveries: [String]
        
        public init(
            team1Score: String,
            team2Score: String,
            status: String,
            currentBatsmen: String = "",
            lastBowling: String = "",
            currentOver: Double = 0.0,
            recentDeliveries: [String] = []
        ) {
            self.team1Score = team1Score
            self.team2Score = team2Score
            self.status = status
            self.currentBatsmen = currentBatsmen
            self.lastBowling = lastBowling
            self.currentOver = currentOver
            self.recentDeliveries = recentDeliveries
        }
    }
    
    public var matchName: String
    public var team1Name: String
    public var team2Name: String
    public var venue: String
    
    public init(
        matchName: String,
        team1Name: String,
        team2Name: String,
        venue: String
    ) {
        self.matchName = matchName
        self.team1Name = team1Name
        self.team2Name = team2Name
        self.venue = venue
    }
}
