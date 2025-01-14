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
    let seriesId: String

    // No need for CodingKeys as we're using .convertFromSnakeCase strategy
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

// End of file. No additional code.
