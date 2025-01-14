import WidgetKit
import SwiftUI
import ActivityKit

// Preview provider
struct CricketScoresLiveActivity_Previews: PreviewProvider {
    static let attributes = CricketActivityAttributes(matchName: "Test Match", team1Name: "Team A", team2Name: "Team B")
    static let contentState = CricketActivityAttributes.ContentState(team1Score: "100/2", team2Score: "95/3", status: "Team A leads by 5 runs")
    
    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}

// Add this comment at the end of the file
// End of file. No additional code.
