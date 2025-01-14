import WidgetKit
import SwiftUI
import ActivityKit

struct CricketLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CricketActivityAttributes.self) { context in
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.team1Name)
                        .font(.caption)
                    Text(context.state.team1Score)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.team2Name)
                        .font(.caption)
                    Text(context.state.team2Score)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } compactLeading: {
                Text(context.state.team1Score)
            } compactTrailing: {
                Text(context.state.team2Score)
            } minimal: {
                Text(context.state.team1Score)
            }
        }
    }
}

struct LiveActivityView: View {
    let context: ActivityViewContext<CricketActivityAttributes>
    
    var body: some View {
        VStack {
            Text(context.attributes.matchName)
                .font(.headline)
            HStack {
                VStack {
                    Text(context.attributes.team1Name)
                    Text(context.state.team1Score)
                        .font(.title)
                }
                Spacer()
                VStack {
                    Text(context.attributes.team2Name)
                    Text(context.state.team2Score)
                        .font(.title)
                }
            }
            Text(context.state.status)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// Preview provider remains unchanged

// End of file. No additional code.
