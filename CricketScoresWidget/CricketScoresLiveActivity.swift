import WidgetKit
import SwiftUI
import ActivityKit

// Your imports remain the same

struct CricketScoresLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CricketActivityAttributes.self) { context in
            // Live Activity UI
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(spacing: 8) {
                    HStack {
                        Text("LIVE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                        Spacer()
                        Text(context.attributes.matchName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    HStack {
                        TeamScoreView(flag: "🇮🇳", teamName: context.attributes.team1Name, score: context.state.team1Score, overs: "(20.0)")
                        Spacer()
                        TeamScoreView(flag: "🇦🇺", teamName: context.attributes.team2Name, score: context.state.team2Score, overs: "(19.0)")
                    }
                    Text(context.state.status)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }
                .padding()
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    TeamScoreView(flag: "🇮🇳", teamName: context.attributes.team1Name, score: context.state.team1Score, overs: "(20.0)")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TeamScoreView(flag: "🇦🇺", teamName: context.attributes.team2Name, score: context.state.team2Score, overs: "(19.0)")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        Text(context.attributes.matchName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                        Text(context.state.status)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        HStack {
                            Text("LIVE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                            Spacer()
                        }
                    }
                }
            } compactLeading: {
                Text(context.attributes.team1Name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            } compactTrailing: {
                Text(context.state.team1Score)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } minimal: {
                Text("\(context.state.team1Score) | \(context.state.team2Score)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct TeamScoreView: View {
    let flag: String
    let teamName: String
    let score: String
    let overs: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(flag)
                Text(teamName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(score)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(overs)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// End of file. No additional code.
