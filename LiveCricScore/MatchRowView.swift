import SwiftUI

struct MatchRowView: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Match Title Section
            Text("\(match.name)")
                .font(.headline)
                .foregroundColor(.primary)

            Text("\(match.matchType), \(match.venue)")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()
                .background(Color.gray.opacity(0.5))

            // Scores Section
            HStack {
                // Team 1
                VStack(alignment: .leading, spacing: 4) {
                                    Text(match.teams[0])
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    let team1Score = getScore(forTeam: 0)
                                    if team1Score != "No score" {
//                                        Text("\(team1Score) (\(getOvers(forTeam: 0)))")
                                        Text("\(team1Score)")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.green)
                                    } else {
                                        Text("Yet to Bat")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                }

                Spacer()

                // Team 2
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.teams[1])
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    let team2Score = getScore(forTeam: 1)
                    if team2Score != "No score" {
//                        Text("\(team2Score) (\(getOvers(forTeam: 1)))")
                        Text("\(team2Score)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.green)
                    } else {
                        Text("Yet to Bat")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }

            }

            // Status Section
            Text(match.status)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.blue)
                .padding(.vertical, 4)
        }
        .padding(16)
        .background(Color(.systemGray6)) // Light background
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // Add this function to safely get team names
    private func getTeamNames() -> String {
        let team1 = match.teamInfo?.first?.shortname ?? match.teams[0]
        let team2 = match.teamInfo?.last?.shortname ?? match.teams[1]
        return "\(team1) vs \(team2)"
    }
    
    // Add this function to safely get score
    private func getScore(forTeam index: Int) -> String {
        guard let score = match.score, index < score.count else {
            return "No score"
        }
        return "\(score[index].r)/\(score[index].w) (\(String(format: "%.1f", score[index].o)))"
    }
        
        // Date formatter function
        private func formattedDate(_ dateString: String) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateFormat = "MMM d, h:mm a"
                return dateFormatter.string(from: date)
            }
            return dateString
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

// End of file. No additional code.
