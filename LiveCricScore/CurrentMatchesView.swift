import SwiftUI

struct CurrentMatchesView: View {
    @StateObject private var viewModel = MatchesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Group {
                    if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            
                            Button("Retry") {
                                viewModel.loadMatches()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.matches) { match in
                                    NavigationLink(destination: MatchDetailView(match: match)) {
                                        MatchRowView(match: match)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.top)
                        }
                        .refreshable {
                            viewModel.loadMatches()
                        }
                    }
                }
                
                if !viewModel.apiUsageInfo.isEmpty {
                    Text(viewModel.apiUsageInfo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.fetchMatches(forceRefresh: true)
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Current Matches")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
