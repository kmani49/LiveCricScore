import SwiftUI
import ActivityKit

// Create a new file named LiveActivityManager.swift

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
        
        let attributes = CricketActivityAttributes(
            matchName: match.name,
            team1Name: match.teams[0],
            team2Name: match.teams[1]
        )
        let contentState = CricketActivityAttributes.ContentState(
            team1Score: "\(match.score?[0].r ?? 0)/\(match.score?[0].w ?? 0)",
            team2Score: "\(match.score?[1].r ?? 0)/\(match.score?[1].w ?? 0)",
            status: match.status
        )
        
        do {
            currentActivity = try Activity<CricketActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
            isLiveActivityEnabled = false
        }
    }
    
    func stopLiveActivity() {
        Task {
            await currentActivity?.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
    
    func checkExistingLiveActivity(for matchName: String) {
        Task {
            for activity in Activity<CricketActivityAttributes>.activities {
                if activity.attributes.matchName == matchName {
                    currentActivity = activity
                    isLiveActivityEnabled = true
                    break
                }
            }
        }
    }
}

// End of file. No additional code.
