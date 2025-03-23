import WidgetKit
import SwiftUI
import ActivityKit

struct CricketScoresLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CricketActivityAttributes.self) { context in
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    CompactTeamView(
                        team: context.attributes.team1Name,
                        score: context.state.team1Score,
                        isBatting: true
                    )
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CompactTeamView(
                        team: context.attributes.team2Name,
                        score: context.state.team2Score,
                        isBatting: false
                    )
                }
                DynamicIslandExpandedRegion(.bottom) {
                    MatchProgressView(
                        currentOver: context.state.currentOver,
                        totalOvers: 20,
                        recentBalls: context.state.recentDeliveries
                    )
                }
            } compactLeading: {
                Text(context.attributes.team1Name.prefix(3))
                    .font(.system(size: 12, weight: .bold))
            } compactTrailing: {
                Text(context.state.team1Score)
                    .font(.system(size: 14, weight: .black))
            } minimal: {
                MinimalScoreView(
                    score1: context.state.team1Score,
                    score2: context.state.team2Score
                )
            }
        }
    }
}

struct LiveActivityView: View {
    let context: ActivityViewContext<CricketActivityAttributes>
    
    // Helper to get match status color
    private var statusColor: Color {
        if context.state.status.lowercased().contains("live") {
            return .red
        } else if context.state.status.lowercased().contains("win") {
            return .green
        } else {
            return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row: Match name and status
            HStack {
                Text(context.attributes.matchName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(context.state.status)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            // Center row: Team scores with VS
            HStack {
                // Team 1
                VStack(alignment: .leading, spacing: 0) {
                    Text(context.attributes.team1Name)
                        .font(.system(size: 15, weight: .medium))
                        .lineLimit(1)
                    
                    Text(context.state.team1Score)
                        .font(.system(size: 30, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // VS divider
                Text("VS")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                
                // Team 2
                VStack(alignment: .trailing, spacing: 0) {
                    Text(context.attributes.team2Name)
                        .font(.system(size: 15, weight: .medium))
                        .lineLimit(1)
                    
                    Text(context.state.team2Score)
                        .font(.system(size: 30, weight: .bold))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Bottom section with match info
            HStack(spacing: 20) {
                // Over info
                Label {
                    Text(String(format: "Over %.1f/20", context.state.currentOver))
                        .font(.system(size: 11))
                        .lineLimit(1)
                } icon: {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                // Venue
                Label {
                    Text(context.attributes.venue)
                        .font(.system(size: 11))
                        .lineLimit(1)
                } icon: {
                    Image(systemName: "mappin.circle")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
            }
            
            // Bottom player info section
            HStack {
                // Bowler
                VStack(alignment: .leading) {
                    Label {
                        Text("Bowler")
                            .font(.system(size: 10))
                    } icon: {
                        Image(systemName: "figure.cricket")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.secondary)
                    
                    Text(extractBowlerName())
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Batsmen
                VStack(alignment: .trailing) {
                    Label {
                        Text("Batsmen")
                            .font(.system(size: 10))
                    } icon: {
                        Image(systemName: "figure.cricket")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.secondary)
                    
                    Text(extractBatsmenNames())
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // Helper methods to extract clean data
        private func extractBowlerName() -> String {
            if context.state.lastBowling.isEmpty { return "--" }
            
            let components = context.state.lastBowling.components(separatedBy: "-")
            if let bowlerName = components.first {
                // Take just the name without stats to avoid overflow
                let name = bowlerName.trimmingCharacters(in: .whitespaces)
                    .components(separatedBy: ":")
                    .first ?? bowlerName
                return name.trimmingCharacters(in: .whitespaces)
            }
            return "--"
        }
        
        private func extractBatsmenNames() -> String {
            if context.state.currentBatsmen.isEmpty { return "--" }
            
            let batsmen = context.state.currentBatsmen.components(separatedBy: ",")
            let names = batsmen.prefix(2).map { batsmanInfo -> String in
                // Extract just name without score to save space
                return batsmanInfo.trimmingCharacters(in: .whitespaces)
                    .components(separatedBy: " ")
                    .first ?? batsmanInfo
            }
            
            return names.joined(separator: ", ")
        }
    }
