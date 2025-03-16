import SwiftUI

// MARK: - Common Components
struct TeamScoreCard: View {
    let team: String
    let score: String
    let overs: String
    let isBatting: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(team)
                    .font(.system(size: 16, weight: .bold))
                
                if isBatting {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.green)
                }
            }
            
            Text(score)
                .font(.system(size: 22, weight: .heavy))
            
            Text("\(overs) ov")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
    }
}

struct LiveStatusIndicator: View {
    let isLive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isLive ? Color.red : Color.gray)
                .frame(width: 6, height: 6)
            
            Text(isLive ? "LIVE" : "ENDED")
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundColor(isLive ? .red : .gray)
        .padding(6)
        .background(Capsule().fill(isLive ? Color.red.opacity(0.2) : Color.gray.opacity(0.2)))
    }
}

struct MatchProgressView: View {
    let currentOver: Double
    let totalOvers: Double
    let recentBalls: [String]
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressBar(current: currentOver, total: totalOvers)
            RecentDeliveriesView(balls: recentBalls)
        }
        .padding(.horizontal, 8)
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
