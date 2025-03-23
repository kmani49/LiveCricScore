import SwiftUI

// MARK: - Common Components
struct TeamScoreCard: View {
    let teamName: String
    let score: String
    let overs: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(teamName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack(spacing: 2) {
                Text(score)
                    .font(.headline.bold())
                Text("(\(overs))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct LiveStatusIndicator: View {
    let isLive: Bool

    var body: some View {
        Circle()
            .fill(isLive ? Color.green : Color.red)
            .frame(width: 6, height: 6)
    }
}

//struct LiveStatusIndicator: View {
//    let isLive: Bool
//    
//    var body: some View {
//        HStack(spacing: 4) {
//            Circle()
//                .fill(isLive ? Color.red : Color.gray)
//                .frame(width: 6, height: 6)
//            
//            Text(isLive ? "LIVE" : "ENDED")
//                .font(.system(size: 12, weight: .bold))
//        }
//        .foregroundColor(isLive ? .red : .gray)
//        .padding(6)
//        .background(Capsule().fill(isLive ? Color.red.opacity(0.2) : Color.gray.opacity(0.2)))
//    }
//}

struct MatchProgressView: View {
    let currentOver: Double
    let totalOvers: Int
    let recentBalls: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Balls: \(recentBalls.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
struct ProgressBar: View {
    let current: Double
    let total: Double
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("\(String(format: "%.1f", current))/\(Int(total))")
                    .font(.system(size: 12, weight: .medium))
                
                Spacer()
                
                Text("CRR: 8.84")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.secondary)
            
            ProgressView(value: current, total: total)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
    }
}

struct RecentDeliveriesView: View {
    let balls: [String]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(balls.prefix(5), id: \.self) { ball in
                Text(ball)
                    .font(.system(size: 11, weight: .bold))
                    .frame(width: 20, height: 20)
                    .foregroundColor(ballColor(for: ball))
                    .background(Circle().stroke(ballColor(for: ball), lineWidth: 1))
            }
        }
    }
    
    private func ballColor(for ball: String) -> Color {
        switch ball {
        case "W": return .red
        case "4", "6": return .green
        default: return .secondary
        }
    }
}

struct CompactTeamView: View {
    let team: String
    let score: String
    let isBatting: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(team)
                .font(.system(size: 14, weight: .semibold))
            Text(score)
                .font(.system(size: 18, weight: .heavy))
            if isBatting {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

struct MinimalScoreView: View {
    let score1: String
    let score2: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(score1)
                .font(.system(size: 10, weight: .black))
            Text("vs")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
            Text(score2)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.white)
    }
}
