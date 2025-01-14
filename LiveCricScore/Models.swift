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
    let seriesId: String?  // This needs explicit coding key
    
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
        case seriesId = "series_id"  // Add this line
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
    let offsetRows: Int
    let totalRows: Int
    let cache: Int  // Change from Bool to Int
}
