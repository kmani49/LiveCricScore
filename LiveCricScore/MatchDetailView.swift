import SwiftUI
import ActivityKit

struct MatchDetailView: View {
    let match: Match
    @State private var selectedTab = "Match Info"
    @State private var activity: Activity<CricketActivityAttributes>? = nil
    @State private var errorMessage: String? = nil
    @State private var isLiveActivityEnabled = false
    @EnvironmentObject private var liveActivityManager: LiveActivityManager

    var body: some View {
        VStack {
            // Tab bar
            HStack {
                ForEach(["Match Info", "Live", "Scoreboard", "Squad"], id: \.self) { tab in
                    Button(action: {
                        self.selectedTab = tab
                    }) {
                        Text(tab)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(self.selectedTab == tab ? Color.black : Color.clear)
                            .foregroundColor(self.selectedTab == tab ? .white : .black)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.bottom, 8.0)
            
            // Content view based on selected tab
            TabView(selection: $selectedTab) {
                MatchInfoView(match: match)
                    .tag("Match Info")
                LiveView(match: match)
                    .tag("Live")
                ScoreboardView(match: match)
                    .tag("Scoreboard")
                SquadView(match: match)
                    .tag("Squad")
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default tab view dots
            // Replace the Button with a Toggle
                       Toggle("Live Activity", isOn: $liveActivityManager.isLiveActivityEnabled)
                           .padding()
                           .onChange(of: liveActivityManager.isLiveActivityEnabled) { oldValue, newValue in
                               if newValue {
                                   liveActivityManager.startLiveActivity(for: match)
                               } else {
                                   Task {
                                       await liveActivityManager.stopLiveActivity()
                                   }
                               }
                           }
                       
                       if let error = errorMessage {
                           Text(error)
                               .foregroundColor(.red)
                               .padding()
                       }
                   }
                   .onAppear {
                       liveActivityManager.checkExistingLiveActivity(for: match.name)
                   }
               }
           }

// End of file. No additional code.
