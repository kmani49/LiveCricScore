import SwiftUI

struct MatchRowView: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with match type and date
            HStack {
                Text(match.matchType.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.blue))
                
                Spacer()
                
                Text(formattedDate(match.dateTimeGMT))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Teams and scores
            VStack(spacing: 8) {
                ForEach(0..<2) { index in
                    if index < match.teams.count {
                        HStack {
                            TeamBadgeView(
                                team: match.teams[index],
                                shortName: match.teamInfo?[index].shortname ?? "",
                                imgURL: match.teamInfo?[index].img
                            )
                            
                            Spacer()
                            
                            if let score = getScore(forTeam: index) {
                                Text(score)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(index == 0 ? .primary : .secondary)
                            }
                            
                            if index == 0 && match.status.contains("Live") {
                                Image(systemName: "seat")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            // Progress and status
            HStack {
                if match.status == "Live" {
                    Text("Play in progress")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Text("Cricket")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
            
            Divider()
            
            // Series info and venue
            HStack {
                Text(match.venue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                if let score = match.score?.first {
                    Text("\(score.r)/\(score.w)")
                        .font(.system(size: 14, weight: .bold))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
        
    private func teamScoreView(teamIndex: Int) -> some View {
        HStack(spacing: 12) {
            // Team Flag/Crest
            if let teamInfo = match.teamInfo, teamIndex < teamInfo.count {
                AsyncImage(url: URL(string: teamInfo[teamIndex].img ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "flag.slash.fill")
                            .foregroundColor(.secondary)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 32, height: 24)
                .cornerRadius(4)
            } else {
                Image(systemName: "flag.slash.fill")
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(match.teams[teamIndex])
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let score = getScore(forTeam: teamIndex) {
                    if score != "No score" {
                        Text(score)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.systemGreen))
                    } else {
                        Text("Yet to Bat")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Yet to Bat")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if teamIndex == 0 && match.status.contains("Live") {
                LiveIndicator()
            }
        }
    }
        
        private var statusIndicator: some View {
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(match.status)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(statusColor)
            }
            .padding(6)
            .background(statusColor.opacity(0.1))
            .cornerRadius(8)
        }
        
        private var venueLabel: some View {
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption2)
                Text(match.venue)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .foregroundColor(.secondary)
        }
        
        private var statusColor: Color {
            if match.status.contains("Live") {
                return .red
            } else if match.status.contains("Complete") {
                return .green
            } else {
                return .orange
            }
        }
        
        private func getTeamNames() -> String {
            let team1 = match.teamInfo?.first?.shortname ?? match.teams[0]
            let team2 = match.teamInfo?.last?.shortname ?? match.teams[1]
            return "\(team1) vs \(team2)"
        }
        
    private func getScore(forTeam index: Int) -> String? {
            guard let scores = match.score, index < scores.count else { return nil }
            return "\(scores[index].r)/\(scores[index].w)"
        }
        
    private func formattedDate(_ dateString: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            guard let date = formatter.date(from: dateString) else { return "" }
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        }
        
        private func getFlag(forTeam index: Int) -> String {
            return match.teamInfo?[index].img ?? ""
        }
        
        private func getOvers(forTeam index: Int) -> String {
            guard let score = match.score, index < score.count else {
                return ""
            }
            return String(format: "%.1f", score[index].o)
        }
}

// MARK: - Live Indicator Component
struct LiveIndicator: View {
    @State private var isBlinking = false
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .opacity(isBlinking ? 0.4 : 1)
                .animation(.easeInOut(duration: 1).repeatForever(), value: isBlinking)
            
            Text("LIVE")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.red.opacity(0.1))
        .cornerRadius(4)
        .onAppear { isBlinking = true }
    }
}

struct TeamBadgeView: View {
    let team: String
    let shortName: String
    let imgURL: String?
    
    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: imgURL ?? "")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else if phase.error != nil {
                    Image(systemName: "flag")
                        .foregroundColor(.secondary)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 24, height: 24)
            .cornerRadius(4)
            
            VStack(alignment: .leading) {
                Text(shortName.isEmpty ? team : shortName)
                    .font(.system(size: 14, weight: .semibold))
                Text(team)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}
