import ActivityKit

struct CricketActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        // Dynamic Values
        var team1Score: String
        var team2Score: String
        var status: String
        var currentOver: Double
        var recentDeliveries: [String]
    }
    
    // Static Values
    let matchName: String
    let team1Name: String
    let team2Name: String
    let venue: String
}
