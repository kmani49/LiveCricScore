import Foundation

struct Match: Identifiable, Codable {
    let id: String
    let name: String
    let status: String
    let venue: String
    let date: String
    let dateTimeGMT: String
    let teams: [String]
    let score: [Score]?
    let teamInfo: [TeamInfo]?
    let matchType: String
    let matchStarted: Bool
    let matchEnded: Bool
    let fantasyEnabled: Bool
    let bbbEnabled: Bool
    let hasSquad: Bool
    var currentBatsmen: [String]?
    var currentBowlers: [String]?
    var overs: Double?

    
    // Add explicit CodingKeys with series_id mapping
    enum CodingKeys: String, CodingKey {
        case id, name, status, venue, date
        case dateTimeGMT = "dateTimeGMT"
        case teams, score
        case teamInfo = "teamInfo"
        case matchType = "matchType"
        case matchStarted = "matchStarted"
        case matchEnded = "matchEnded"
        case fantasyEnabled = "fantasyEnabled"
        case bbbEnabled = "bbbEnabled"
        case hasSquad = "hasSquad"
    }
}

// Update the Score struct
struct Score: Identifiable, Codable {
    let r: Int
    let w: Int
    let o: Double
    let inning: String
    
    var id: String { inning }
}

// Update the TeamInfo struct
struct TeamInfo: Codable {
    let name: String
    let shortname: String
    let img: String?
}

struct APIResponse: Codable {
    let apikey: String  // Add this missing field
    let data: [Match]
    let status: String
    let info: APIInfo
}

struct APIInfo: Codable {
    let hitsToday: Int
    let hitsUsed: Int
    let hitsLimit: Int
    let credits: Int
    let server: Int
    let queryTime: Double  // Changed from offsetRows
    let s: Int             // Changed from totalRows
    let cache: Int
    
    enum CodingKeys: String, CodingKey {
        case hitsToday, hitsUsed, hitsLimit, credits
        case server, queryTime, s, cache
    }
}

struct IPLSeriesResponse: Codable {
    let apikey: String
    let data: IPLSeriesData
    let status: String
    let info: APIInfo  // This matches the root-level "info" in the JSON
}

struct IPLSeriesData: Codable {
    let info: SeriesInfo
    let matchList: [Match]
}

struct SeriesInfo: Codable {
    let id: String
    let name: String
    let startdate: String
    let enddate: String
    let odi: Int
    let t20: Int
    let test: Int
    let squads: Int
    let matches: Int
    
    // Add computed properties for formatted dates
    var formattedStartDate: String {
        formatDateString(startdate)
    }
    
    var formattedEndDate: String {
        formatDateString(enddate)
    }
    
    private func formatDateString(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}
