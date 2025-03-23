import SwiftUI
import Combine

class IPLMatchesViewModel: ObservableObject {
    @Published var todaysMatches: [Match] = []
    @Published var upcomingMatches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiUrl = "https://api.cricapi.com/v1/series_info?apikey=a6eb7070-0e28-4b59-88ea-3ef05a93a6d5&offset=0&id=d5a498c8-7596-4b93-8ab0-e0efc3345312"
    
    init() {
        fetchIPLMatches()
    }
    
    func fetchIPLMatches() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: apiUrl) else {
            handleError(NetworkError.invalidURL)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: IPLSeriesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] response in
                self?.processMatches(response.data.matchList)
            }
            .store(in: &cancellables)
    }
    
    private func processMatches(_ matches: [Match]) {
        let now = Date()
        let calendar = Calendar.current
        
        todaysMatches = matches.filter { match in
            guard let date = dateFormatter.date(from: match.dateTimeGMT) else { return false }
            return calendar.isDateInToday(date) && date > now
        }.sorted { $0.dateTimeGMT < $1.dateTimeGMT }
        
        upcomingMatches = matches.filter { match in
            guard let date = dateFormatter.date(from: match.dateTimeGMT) else { return false }
            return date > now && !calendar.isDateInToday(date)
        }.sorted { $0.dateTimeGMT < $1.dateTimeGMT }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
    }
}



    
// Add error response model
struct APIErrorResponse: Codable {
    let error: String
}

