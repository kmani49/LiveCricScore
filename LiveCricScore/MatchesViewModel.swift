import SwiftUI
import Combine

struct CacheItem: Codable {
    let data: [Match]
    let timestamp: Date
}

class MatchesViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var apiUsageInfo = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let cacheKey = "cached_matches"
    private let cacheInterval: TimeInterval = 300
    private let apiUrl = "https://api.cricapi.com/v1/currentMatches?apikey=a6eb7070-0e28-4b59-88ea-3ef05a93a6d5&offset=0"
    
    // Configure custom decoder
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    init() {
        print("Initializing ViewModel")
        loadMatches()
    }
    
    func loadMatches() {
        print("Attempting to load matches")
        fetchMatches()
    }
    
    func fetchMatches(forceRefresh: Bool = false) {
        print("Fetch matches called. Force refresh: \(forceRefresh)")
        
        if !forceRefresh, let cachedData = loadFromCache() {
            print("Loading from cache")
            self.matches = cachedData
            return
        }
        
        guard !isLoading else {
            print("Already loading, aborting")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: apiUrl) else {
            handleError(NetworkError.invalidURL)
            return
        }
        
        print("Starting network request to \(url)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    let statusCode = httpResponse.statusCode
                    print("Server error: HTTP \(statusCode)")
                    throw NetworkError.serverError(statusCode: statusCode)
                }
                
                print("Received valid response")
                return data
            }
            .handleEvents(receiveOutput: { data in
                print("Raw API response:\n\(String(data: data, encoding: .utf8) ?? "Invalid data")")
            })
            .decode(type: APIResponse.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    print("Request completed successfully")
                case .failure(let error):
                    print("Request failed with error: \(error.localizedDescription)")
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] response in
                print("Successfully decoded \(response.data.count) matches")
                self?.matches = response.data
                self?.cacheMatches(data: response.data)
                self?.updateAPIUsageInfo(hitsUsed: response.info.hitsUsed, hitsLimit: response.info.hitsLimit)
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        print("Handling error: \(error)")
        errorMessage = "Error: \(error.localizedDescription)"
        isLoading = false
        
        if let decodingError = error as? DecodingError {
            handleDecodingError(decodingError)
        }
    }
    
    private func handleDecodingError(_ error: DecodingError) {
        print("Decoding error details:")
        switch error {
        case .typeMismatch(let type, let context):
            print("Type mismatch for \(type): \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        case .valueNotFound(let type, let context):
            print("Value not found for \(type): \(context.debugDescription)")
            print("Coding path: \(context.codingPath)")
        case .keyNotFound(let key, let context):
            print("Key not found: \(key.stringValue)")
            print("Coding path: \(context.codingPath)")
        case .dataCorrupted(let context):
            print("Data corrupted: \(context.debugDescription)")
        default:
            print("Unknown decoding error")
        }
    }
    
    private func updateAPIUsageInfo(hitsUsed: Int, hitsLimit: Int) {
        apiUsageInfo = "API Usage: \(hitsUsed)/\(hitsLimit)"
        print("Updated API usage info: \(apiUsageInfo)")
    }
    
    private func loadFromCache() -> [Match]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            print("No cached data found")
            return nil
        }
        
        do {
            let cacheItem = try decoder.decode(CacheItem.self, from: data)
            let age = Date().timeIntervalSince(cacheItem.timestamp)
            guard age < cacheInterval else {
                print("Cache expired (age: \(age) seconds)")
                return nil
            }
            print("Loading valid cached data (\(Int(age))s old)")
            return cacheItem.data
        } catch {
            print("Failed to decode cache: \(error)")
            return nil
        }
    }
    
    private func cacheMatches(data: [Match]) {
        do {
            let cacheItem = CacheItem(data: data, timestamp: Date())
            let encoded = try JSONEncoder().encode(cacheItem)
            UserDefaults.standard.set(encoded, forKey: cacheKey)
            print("Successfully cached \(data.count) matches")
        } catch {
            print("Failed to cache matches: \(error)")
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .invalidResponse: return "Invalid server response"
        case .serverError(let code): return "Server error (HTTP \(code))"
        }
    }
}
