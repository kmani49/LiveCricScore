import SwiftUI
import ActivityKit

@MainActor
class LiveActivityManager: ObservableObject {
    @Published var isLiveActivityEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isLiveActivityEnabled, forKey: "isLiveActivityEnabled")
        }
    }
    @Published var currentActivity: Activity<CricketActivityAttributes>? = nil
    
    init() {
        self.isLiveActivityEnabled = UserDefaults.standard.bool(forKey: "isLiveActivityEnabled")
    }
    
    func startLiveActivity(for match: Match) {
        guard isLiveActivityEnabled else { return }
        
        // Format dates
        let dateFormatter = ISO8601DateFormatter()
        let matchDate = dateFormatter.date(from: match.dateTimeGMT) ?? Date()
        
        let attributes = CricketActivityAttributes(
            matchName: match.name,
            team1Name: match.teams[0],
            team2Name: match.teams[1],
            venue: match.venue  // Add venue
        )
        
        let contentState = CricketActivityAttributes.ContentState(
            team1Score: "210/5",
            team2Score: "48/2",
            status: "Live",
            currentOver: 5.4,
            recentDeliveries: ["W", "0", "4", "1LB", "0"]
        )
        
        do {
            currentActivity = try Activity<CricketActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: matchDate))
        )} catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
            isLiveActivityEnabled = false
        }
    }
    
    // Helper methods
    private func getCurrentBatsmen(from match: Match) -> String {
        // Implement your logic to get current batsmen
        return "R Sharma, V Kohli" // Example
    }
    
    private func getLastBowlerStats(from match: Match) -> String {
        // Implement your logic to get bowler stats
        return "J Bumrah: 4-0-20-1" // Example
    }
    
    private func getCurrentOver(from match: Match) -> Double {
        // Implement your logic to get current over
        return match.score?.first?.o ?? 0.0
    }
    
    func stopLiveActivity() async {
            if let activity = currentActivity {
                await activity.end(nil, dismissalPolicy: .immediate)
                currentActivity = nil
            }
    }
    
    func checkExistingLiveActivity(for matchName: String) {
            Task {
                for activity in Activity<CricketActivityAttributes>.activities {
                    if activity.attributes.matchName == matchName {
                        await MainActor.run {
                            currentActivity = activity
                            isLiveActivityEnabled = true
                        }
                        break
                    }
                }
            }
        }
}
