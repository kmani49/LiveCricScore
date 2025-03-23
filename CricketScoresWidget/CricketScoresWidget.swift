import WidgetKit
import SwiftUI
import ActivityKit

// Preview provider
struct CricketScoresLiveActivity_Previews: PreviewProvider {
    // Define static properties for preview
    static let attributes = CricketActivityAttributes(
        matchName: "ICC T20 World Cup",
        team1Name: "India",
        team2Name: "Australia",
        venue: "Wankhede Stadium, Mumbai"
    )

    static let liveContentState = CricketActivityAttributes.ContentState(
        team1Score: "210-5",
        team2Score: "48-2",
        status: "LIVE",
        currentBatsmen: "R Sharma 32, V Kohli 24",  // Format with scores
        lastBowling: "M Starc - 3.5-0-28-1",     // More detailed bowling stats
        currentOver: 5.4,
        recentDeliveries: ["4", "0", "W", "1", "6", "2"]  // Add sample deliveries
    )
    
    static let inningsBreakContentState = CricketActivityAttributes.ContentState(
        team1Score: "210-5",
        team2Score: "Yet to bat",
        status: "INNINGS BREAK",
        currentBatsmen: "",
        lastBowling: "",
        currentOver: 20.0,
        recentDeliveries: []
    )
    
    static let matchEndContentState = CricketActivityAttributes.ContentState(
        team1Score: "210-5",
        team2Score: "208-6",
        status: "IND WIN BY 2 RUNS",
        currentBatsmen: "",
        lastBowling: "",
        currentOver: 20.0,
        recentDeliveries: []
    )
    
    static var previews: some View {
        Group {
            // Live match previews
            attributes
                .previewContext(liveContentState, viewKind: .dynamicIsland(.compact))
                .previewDisplayName("Live - Compact")
            attributes
                .previewContext(liveContentState, viewKind: .dynamicIsland(.expanded))
                .previewDisplayName("Live - Expanded")
            attributes
                .previewContext(liveContentState, viewKind: .dynamicIsland(.minimal))
                .previewDisplayName("Live - Minimal")
            
            // Innings break previews
            attributes
                .previewContext(inningsBreakContentState, viewKind: .dynamicIsland(.expanded))
                .previewDisplayName("Innings Break")
            
            // Match end previews
            attributes
                .previewContext(matchEndContentState, viewKind: .dynamicIsland(.expanded))
                .previewDisplayName("Match End")
            
            // Notification preview
            attributes
                .previewContext(liveContentState, viewKind: .content)
                .previewDisplayName("Notification")
        }
    }
}
