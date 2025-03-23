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
        NavigationStack {
            VStack(spacing: 20) {
                // IPL 2025 Card
                NavigationLink(destination: IPLMatchesView()) {
                    SeriesCardView(
                        title: "IPL 2025",
                        subtitle: "Indian Premier League",
                        icon: "trophony.fill"
                    )
                }
                
                // Ongoing Matches Card
                NavigationLink(destination: CurrentMatchesView()) {
                    SeriesCardView(
                        title: "Ongoing Matches",
                        subtitle: "Live & Upcoming Games",
                        icon: "livephoto.play"
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Cricket Hub")
            .navigationBarTitleDisplayMode(.large)
        }
        .accentColor(.indigo)
        .environmentObject(liveActivityManager)
    }
}

struct IPLMatchesView: View {
    @StateObject private var viewModel = IPLMatchesViewModel()
    @State private var selectedMatch: Match?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Matches Section
                    if !viewModel.todaysMatches.isEmpty {
                        SectionHeader(title: "Today's Matches")
                        ForEach(viewModel.todaysMatches) { match in
                            MatchCard(match: match, showCountdown: true)
                        }
                    }
                    
                    // Upcoming Matches Section
                    if !viewModel.upcomingMatches.isEmpty {
                        SectionHeader(title: "Upcoming Matches")
                        ForEach(viewModel.upcomingMatches) { match in
                            MatchCard(match: match, showCountdown: false)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("IPL 2025")
            .background(Color(.systemGroupedBackground))
            .overlay(loadingView)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .navigationViewStyle(.stack)
        .refreshable {
            viewModel.fetchIPLMatches()
        }
    }
    private var loadingView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground).opacity(0.9))
            }
        }
    }
}// MARK: - Components
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Missing Components Implementation
struct CountdownView: View {
    @Binding var timeRemaining: String
    let dateString: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Starts in")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(timeRemaining)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
        }
        .onAppear {
            updateTimeRemaining()
            startTimer()
        }
    }
    
    private func startTimer() {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { _ in
                updateTimeRemaining()
            }
            .store(in: &cancellables)
    }
    
    private func updateTimeRemaining() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        
        guard let matchDate = formatter.date(from: dateString) else {
            timeRemaining = "-"
            return
        }
        
        let remaining = matchDate.timeIntervalSince(Date())
        guard remaining > 0 else {
            timeRemaining = "LIVE"
            return
        }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = (Int(remaining) % 3600) % 60
        timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

struct MatchTimingView: View {
    let date: String
    let timeGMT: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(formattedDate)
                .font(.subheadline)
            
            Text(formattedTime)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: date) else { return self.date }
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        guard let date = formatter.date(from: timeGMT) else { return "N/A" }
        
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
}

struct MatchCard: View {
    let match: Match
    let showCountdown: Bool
    @State private var timeRemaining: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            teamsSection
            matchStatusSection
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .onAppear {
            if showCountdown {
                startTimer()
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(match.venue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(match.name)
                    .font(.headline)
                    .lineLimit(2)
            }
            
            Spacer()
            
            MatchStatusIndicator(status: match.status)
        }
    }
    
    private var teamsSection: some View {
        HStack(spacing: 16) {
            TeamView(name: match.teams.first ?? "Team A")
            VsView()
            TeamView(name: match.teams.last ?? "Team B")
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
    
    private var matchStatusSection: some View {
        Group {
            if match.status == "Match started" {
                ScoreView(score: match.score?.first)
            } else if showCountdown {
                CountdownView(timeRemaining: $timeRemaining, dateString: match.dateTimeGMT)
            } else {
                MatchTimingView(date: match.date, timeGMT: match.dateTimeGMT)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func startTimer() {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { _ in
                updateTimeRemaining()
            }
            .store(in: &cancellables)
    }
    
    private func updateTimeRemaining() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        
        guard let matchDate = formatter.date(from: match.dateTimeGMT) else {
            timeRemaining = "-"
            return
        }
        
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        timer
            .map { _ in
                let remaining = matchDate.timeIntervalSince(Date())
                guard remaining > 0 else { return "LIVE" }
                
                let hours = Int(remaining) / 3600
                let minutes = (Int(remaining) % 3600) / 60
                let seconds = (Int(remaining) % 3600) % 60
                return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }
            .assign(to: \.timeRemaining, on: self)
            .store(in: &cancellables)
    }
    @State private var cancellables = Set<AnyCancellable>()
}

struct TeamView: View {
    let name: String
    
    var body: some View {
        VStack {
            Image(name.replacingOccurrences(of: " ", with: "").lowercased())
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text(name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
    }
}

struct VsView: View {
    var body: some View {
        Text("vs")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(8)
            .background(Circle().stroke(Color.secondary))
    }
}

struct ScoreView: View {
    let score: Score?
    
    var body: some View {
        VStack {
            Text("Current Score")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Text("\(score?.r ?? 0)/\(score?.w ?? 0)")
                    .font(.title2)
                Text("(\(score?.o ?? 0.0) ov)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct MatchStatusIndicator: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption2)
            .padding(6)
            .background(statusBackground)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    private var statusBackground: Color {
        switch status {
        case "Match started": return .green
        case "Match ended": return .red
        default: return .orange
        }
    }
}

// Existing code ...

struct SeriesCardView: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.indigo)
                
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .contentShape(Rectangle())
    }
}

// Existing code ...

struct StatBadge: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
    }
}

struct DetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(text)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct StatBlock: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CommentaryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Commentary")
                .font(.headline)
            
            ForEach(0..<3) { _ in
                VStack(alignment: .leading, spacing: 4) {
                    Text("4.2 overs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Wide ball, outside off stump")
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// Existing code ...

struct MatchInfoView: View {
    let match: Match
    
    private let cardBackground = LinearGradient(
        gradient: Gradient(colors: [Color(.systemIndigo), Color(.systemTeal)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(match.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(formattedDate(match.dateTimeGMT))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(match.matchType.uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(4)
                            .background(Capsule().fill(Color.indigo.opacity(0.2)))
                            .foregroundColor(.indigo)
                    }
                }
                .padding(.horizontal)
                
                // Score Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(match.teams[0])
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("\(match.score?[0].r ?? 0)/\(match.score?[0].w ?? 0)")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("\(String(format: "%.1f", match.score?[0].o ?? 0)) Overs")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            StatBadge(title: "CRR", value: "8.84")
                            StatBadge(title: "REQ", value: "37.0")
                        }
                    }
                    
                    ProgressView(value: 0.65)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .padding(.vertical, 4)
                    
                    Text(match.status)
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(cardBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                
                // Match Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "mappin.circle", text: match.venue)
                    DetailRow(icon: "calendar", text: formattedDate(match.dateTimeGMT))
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Quick Stats
                HStack {
                    StatBlock(title: "Partnership", value: "15(14)")
                    Divider()
                    StatBlock(title: "Last 5 Overs", value: "45/1")
                    Divider()
                    StatBlock(title: "Target", value: "\(match.score?[1].r ?? 0 + 1)")
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Players Section
                BattersTable(score: match.score?[0] ?? Score(r: 0, w: 0, o: 0, inning: ""))
                    .padding(.horizontal)
                
                BowlerTable(score: match.score?[1] ?? Score(r: 0, w: 0, o: 0, inning: ""))
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Match Details")
        .navigationBarTitleDisplayMode(.inline)
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
        VStack(spacing: 0) {
            HeaderRow(items: ["Batter", "R", "B", "4s", "6s", "SR"])
            
            Divider()
            
            BatterRow(name: "Player 1", r: "\(score.r)", b: "0", fours: "0", sixes: "0", sr: "0.00")
            Divider()
            BatterRow(name: "Player 2", r: "0", b: "0", fours: "0", sixes: "0", sr: "0.00")
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.vertical, 8)
    }
    
    private func HeaderRow(items: [String]) -> some View {
        HStack {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(r).frame(maxWidth: .infinity)
                Text(b).frame(maxWidth: .infinity)
                Text(fours).frame(maxWidth: .infinity)
                Text(sixes).frame(maxWidth: .infinity)
                Text(sr).frame(maxWidth: .infinity)
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.vertical, 6)
            .padding(.horizontal)
        }
    }
}
struct BowlerTable: View {
    let score: Score
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderRow(items: ["Bowler", "O", "M", "R", "W", "Econ"])
            
            Divider()
            
            BowlerRow(name: "Bowler 1", o: "\(score.o)", m: "0", r: "\(score.r)", w: "0", econ: "0.00")
            Divider()
            BowlerRow(name: "Bowler 2", o: "0", m: "0", r: "0", w: "0", econ: "0.00")
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.vertical, 8)
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(o).frame(maxWidth: .infinity)
                Text(m).frame(maxWidth: .infinity)
                Text(r).frame(maxWidth: .infinity)
                Text(w).frame(maxWidth: .infinity)
                Text(econ).frame(maxWidth: .infinity)
            }
            .font(.system(size: 14, weight: .medium))
            .padding(.vertical, 6)
            .padding(.horizontal)
        }
    }
    
    private func HeaderRow(items: [String]) -> some View {
        HStack {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

// Preview remains the same
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LiveActivityManager())
    }
}
