import SwiftUI
import Foundation
import Combine
import ActivityKit



@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct ContentView: View {
    @StateObject private var liveActivityManager = LiveActivityManager()

    var body: some View {
        TabView {
            CurrentMatchesView()
                .tabItem {
                    Label("Current Matches", systemImage: "sportscourt")
                }
            
            Text("Other Tab") // Placeholder for other tabs
                .tabItem {
                    Label("Other", systemImage: "star")
                }
        }
        .environmentObject(liveActivityManager)
    }
}

struct MatchInfoView: View {
    let match: Match
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(match.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Match status card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(match.teams[0])
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("CRR")
                                .font(.caption)
                            Text("REQ")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        VStack(alignment: .trailing) {
                            // Replace with actual CRR and REQ calculations
                            Text("8.84")
                                .font(.caption)
                            Text("37.0")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                    }
                    HStack {
                        Text("\(match.score?[0].r ?? 0)-\(match.score?[0].w ?? 0) (\(String(format: "%.1f", match.score?[0].o ?? 0)))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    Text(match.status)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                
                Text("Venue: \(match.venue)")
                    .font(.subheadline)
                
                Text("Date: \(formattedDate(match.dateTimeGMT))")
                    .font(.subheadline)
                
                Text("Match Type: \(match.matchType)")
                    .font(.subheadline)
            }
            .padding()
        }
    }

    
    private func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMMM d, yyyy h:mm a"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}
struct LiveView: View {
    let match: Match
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Match status card (similar to MatchInfoView)
                VStack(alignment: .leading, spacing: 8) {
                    // ... (similar to MatchInfoView's status card)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(match.teams[0])
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("CRR")
                                    .font(.caption)
                                Text("REQ")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            VStack(alignment: .trailing) {
                                // Replace with actual CRR and REQ calculations
                                Text("8.84")
                                    .font(.caption)
                                Text("37.0")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        HStack {
                            Text("\(match.score?[0].r ?? 0)-\(match.score?[0].w ?? 0) (\(String(format: "%.1f", match.score?[0].o ?? 0)))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        Text(match.status)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Match details
                VStack(alignment: .leading, spacing: 8) {
                    Text("TARGET : \(match.score?[1].r ?? 0 + 1) RUNS")
                        .font(.subheadline)
                    Text("PARTNERSHIP 15(14)")
                        .font(.subheadline)
                    
                    // Batters table
                    BattersTable(score: match.score?[0] ?? Score(r: 0, w: 0, o: 0, inning: ""))
                    
                    // Bowler table
                    BowlerTable(score: match.score?[1] ?? Score(r: 0, w: 0, o: 0, inning: ""))
                    
                    // Commentary
                    CommentaryView()
                }
                .padding()
            }
        }
    }
}

struct ScoreboardView: View {
    let match: Match
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Scoreboard").font(.largeTitle)
                
                ForEach(match.score ?? [], id: \.inning) { score in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(score.inning)
                            .font(.headline)
                        Text("Score: \(score.r)/\(score.w)")
                        Text("Overs: \(String(format: "%.1f", score.o))")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct SquadView: View {
    let match: Match
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Squad").font(.largeTitle)
                
                ForEach(match.teamInfo ?? [], id: \.name) { team in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(team.name)
                            .font(.headline)
                        Text("Short Name: \(team.shortname)")
                        if let img = team.img {
                            AsyncImage(url: URL(string: img)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

// Helper views
struct BattersTable: View {
    let score: Score
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack {
                Text("BATTER").font(.caption).foregroundColor(.gray)
                Spacer()
                HStack {
                    Text("R").font(.caption).foregroundColor(.gray)
                    Text("B").font(.caption).foregroundColor(.gray)
                    Text("4s").font(.caption).foregroundColor(.gray)
                    Text("6s").font(.caption).foregroundColor(.gray)
                    Text("SR").font(.caption).foregroundColor(.gray)
                }.padding(.trailing, 20.0)
            }
            // Replace with actual batter data when available
            BatterRow(name: "Player 1", r: "\(score.r)", b: "0", fours: "0", sixes: "0", sr: "0.00")
            BatterRow(name: "Player 2", r: "0", b: "0", fours: "0", sixes: "0", sr: "0.00")
        }
    }
    struct BatterRow: View {
        let name: String
        let r: String
        let b: String
        let fours: String
        let sixes: String
        let sr: String
        var body: some View {
            HStack {
                Text(name)
                Spacer()
                Text(r)
                Text(b)
                Text(fours)
                Text(sixes)
                Text(sr)
            }
        }
    }
}
struct BowlerTable: View {
    let score: Score
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack {
                Text("BOWLER").font(.caption).foregroundColor(.gray)
                Spacer()
                HStack {
                    Text("O").font(.caption).foregroundColor(.gray)
                    Text("M").font(.caption).foregroundColor(.gray)
                    Text("R").font(.caption).foregroundColor(.gray)
                    Text("W").font(.caption).foregroundColor(.gray)
                    Text("Econ").font(.caption).foregroundColor(.gray)
                }.padding(.trailing, 20.0)
            }
            // Replace with actual bowler data when available
            BowlerRow(name: "Bowler 1", o: "\(score.o)", m: "0", r: "\(score.r)", w: "0", econ: "0.00")
            BowlerRow(name: "Bowler 2", o: "0", m: "0", r: "0", w: "0", econ: "0.00")
        }
    }
    struct BowlerRow: View {
        let name: String
        let o: String
        let m: String
        let r: String
        let w: String
        let econ: String
        var body: some View {
            HStack {
                Text(name)
                Spacer()
                Text(o)
                Text(m)
                Text(r)
                Text(w)
                Text(econ)
            }
        }
    }
}
struct CommentaryView: View {
    var body: some View {
        Text("Commentary will go here")
    }
}



// Preview remains the same
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LiveActivityManager())
    }
}

// End of file. No additional code.
