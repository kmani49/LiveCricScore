import Foundation
import Combine

// Add APIResponse structure
struct APIResponse: Codable {
    let apikey: String
    let data: [Match]
    let status: String
    let info: Info
}

// Add Info structure
struct Info: Codable {
    let hitsToday: Int
    let hitsUsed: Int
    let hitsLimit: Int
    let credits: Int
    let server: Int
    let offsetRows: Int
    let totalRows: Int
    let queryTime: Double
    let s: Int
    let cache: Int
}

class MatchesViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let cacheKey = "cachedMatches"
    private let cacheExpiration: TimeInterval = 300 // 5 minutes
    
    // Static API response data
    private let staticAPIResponse = """
        {
          "apikey": "a6eb7070-0e28-4b59-88ea-3ef05a93a6d5",
          "data": [
            {
              "id": "aa5f59b2-00d4-4c16-9bcd-20322cfe51fa",
              "name": "Rwanda vs Botswana, 10th Match",
              "matchType": "t20",
              "status": "Botswana won by 6 wkts",
              "venue": "Gahanga International Cricket Stadium, Kigali City",
              "date": "2024-12-08",
              "dateTimeGMT": "2024-12-08T11:15:00",
              "teams": [
                "Rwanda",
                "Botswana"
              ],
              "score": [
                {
                  "r": 111,
                  "w": 8,
                  "o": 20,
                  "inning": "Rwanda Inning 1"
                },
                {
                  "r": 115,
                  "w": 4,
                  "o": 16.2,
                  "inning": "Botswana Inning 1"
                }
              ],
              "series_id": "1a85ba08-05cd-4a00-9894-4f4f2b9e1d3d",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "15947479-8e2d-4f37-a65f-bf54a16e3010",
              "name": "Nigeria vs Uganda, 9th Match",
              "matchType": "t20",
              "status": "Uganda won by 7 wkts",
              "venue": "Gahanga International Cricket Stadium, Kigali City",
              "date": "2024-12-08",
              "dateTimeGMT": "2024-12-08T07:15:00",
              "teams": [
                "Nigeria",
                "Uganda"
              ],
              "score": [
                {
                  "r": 103,
                  "w": 10,
                  "o": 19,
                  "inning": "Nigeria Inning 1"
                },
                {
                  "r": 107,
                  "w": 3,
                  "o": 13,
                  "inning": "Uganda Inning 1"
                }
              ],
              "series_id": "1a85ba08-05cd-4a00-9894-4f4f2b9e1d3d",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "edee5ae9-308b-44a7-870b-b7a15a9ecf97",
              "name": "Botswana vs Nigeria, 8th Match",
              "matchType": "t20",
              "status": "Botswana won by 3 wkts",
              "venue": "Gahanga International Cricket Stadium, Kigali City",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T11:15:00",
              "teams": [
                "Botswana",
                "Nigeria"
              ],
              "score": [
                {
                  "r": 141,
                  "w": 9,
                  "o": 20,
                  "inning": "Nigeria Inning 1"
                },
                {
                  "r": 142,
                  "w": 7,
                  "o": 19.5,
                  "inning": "Botswana Inning 1"
                }
              ],
              "series_id": "1a85ba08-05cd-4a00-9894-4f4f2b9e1d3d",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "ff7d160f-1b7e-42fc-8969-d719874d0c3c",
              "name": "Rwanda vs Uganda, 7th Match",
              "matchType": "t20",
              "status": "Uganda won by 86 runs",
              "venue": "Gahanga International Cricket Stadium, Kigali City",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T07:15:00",
              "teams": [
                "Rwanda",
                "Uganda"
              ],
              "score": [
                {
                  "r": 151,
                  "w": 8,
                  "o": 20,
                  "inning": "Uganda Inning 1"
                },
                {
                  "r": 65,
                  "w": 10,
                  "o": 17,
                  "inning": "Rwanda Inning 1"
                }
              ],
              "series_id": "1a85ba08-05cd-4a00-9894-4f4f2b9e1d3d",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "c115ecc8-2b1d-4d6b-9d99-c88f6a610f41",
              "name": "Panama vs Cayman Islands, Match 8",
              "matchType": "t20",
              "status": "Cayman Islands won by 83 runs",
              "venue": "St Georges College Ground, Quilmes, Buenos Aires",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T17:30:00",
              "teams": [
                "Panama",
                "Cayman Islands"
              ],
              "score": [
                {
                  "r": 124,
                  "w": 6,
                  "o": 20,
                  "inning": "Cayman Islands Inning 1"
                },
                {
                  "r": 41,
                  "w": 10,
                  "o": 15,
                  "inning": "Panama Inning 1"
                }
              ],
              "series_id": "990b13f1-4bc6-4d71-9607-d9e78696cbbc",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "fde36590-59a3-427b-bdc5-a90ff9f53441",
              "name": "Suriname vs Bermuda, Match 7",
              "matchType": "t20",
              "status": "Bermuda won by 92 runs",
              "venue": "Hurlingham Club Ground, Hurlingham, Buenos Aires",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T17:30:00",
              "teams": [
                "Suriname",
                "Bermuda"
              ],
              "score": [
                {
                  "r": 161,
                  "w": 7,
                  "o": 20,
                  "inning": "Bermuda Inning 1"
                },
                {
                  "r": 69,
                  "w": 9,
                  "o": 20,
                  "inning": "Suriname Inning 1"
                }
              ],
              "series_id": "990b13f1-4bc6-4d71-9607-d9e78696cbbc",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "106fe371-8a61-4f64-b5d5-305bc623feb8",
              "name": "Belize vs Argentina, Match 6",
              "matchType": "t20",
              "status": "Argentina won by 5 runs",
              "venue": "St Georges College Ground, Quilmes, Buenos Aires",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T13:30:00",
              "teams": [
                "Belize",
                "Argentina"
              ],
              "score": [
                {
                  "r": 101,
                  "w": 10,
                  "o": 19.3,
                  "inning": "Argentina Inning 1"
                },
                {
                  "r": 96,
                  "w": 10,
                  "o": 19.1,
                  "inning": "Belize Inning 1"
                }
              ],
              "series_id": "990b13f1-4bc6-4d71-9607-d9e78696cbbc",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "435f277c-11dd-420e-be7e-f0f1d7b01870",
              "name": "Brazil vs Mexico, Match 5",
              "matchType": "t20",
              "status": "Mexico won by 47 runs",
              "venue": "Hurlingham Club Ground, Hurlingham, Buenos Aires",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T13:30:00",
              "teams": [
                "Brazil",
                "Mexico"
              ],
              "score": [
                {
                  "r": 102,
                  "w": 10,
                  "o": 20,
                  "inning": "Mexico Inning 1"
                },
                {
                  "r": 55,
                  "w": 10,
                  "o": 14.4,
                  "inning": "Brazil Inning 1"
                }
              ],
              "series_id": "990b13f1-4bc6-4d71-9607-d9e78696cbbc",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "3cbc966b-d628-485d-89a9-fa9d191d1ef1",
              "name": "Qatar Women vs Bahrain Women, 5th Match",
              "matchType": "t20",
              "status": "Qatar Women won by 4 wkts",
              "venue": "West End Park International Cricket Stadium, Doha",
              "date": "2024-12-08",
              "dateTimeGMT": "2024-12-08T08:00:00",
              "teams": [
                "Qatar Women",
                "Bahrain Women"
              ],
              "score": [
                {
                  "r": 128,
                  "w": 4,
                  "o": 20,
                  "inning": "Bahrain Women Inning 1"
                },
                {
                  "r": 131,
                  "w": 6,
                  "o": 18.4,
                  "inning": "Qatar Women Inning 1"
                }
              ],
              "series_id": "449b28a7-38f0-4abc-b2ae-e1bf7bff513c",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "1d0ae71f-39a8-4458-8283-dd4ebe0ca157",
              "name": "Qatar Women vs Bahrain Women, 4th Match",
              "matchType": "t20",
              "status": "Qatar Women won by 9 wkts",
              "venue": "West End Park International Cricket Stadium, Doha",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T10:00:00",
              "teams": [
                "Qatar Women",
                "Bahrain Women"
              ],
              "score": [
                {
                  "r": 128,
                  "w": 8,
                  "o": 20,
                  "inning": "Bahrain Women Inning 1"
                },
                {
                  "r": 129,
                  "w": 1,
                  "o": 15,
                  "inning": "Qatar Women Inning 1"
                }
              ],
              "series_id": "449b28a7-38f0-4abc-b2ae-e1bf7bff513c",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "dbb65ead-3cad-4389-9f3f-da0796a72968",
              "name": "Thailand Women vs Namibia Women, Final",
              "matchType": "t20",
              "status": "Thailand Women won by 30 runs",
              "venue": "Mission Road Ground, Mong Kok",
              "date": "2024-12-08",
              "dateTimeGMT": "2024-12-08T06:00:00",
              "teams": [
                "Thailand Women",
                "Namibia Women"
              ],
              "score": [
                {
                  "r": 72,
                  "w": 10,
                  "o": 18.5,
                  "inning": "Thailand Women Inning 1"
                },
                {
                  "r": 42,
                  "w": 10,
                  "o": 16.2,
                  "inning": "Namibia Women Inning 1"
                }
              ],
              "series_id": "e2f571bd-db63-4a12-ac59-893509cf247b",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "f0b40ee4-0595-48d1-a279-31b0bcaa8077",
              "name": "Hong Kong Women vs China Women, 3rd place play-off",
              "matchType": "t20",
              "status": "Hong Kong Women won by 32 runs",
              "venue": "Mission Road Ground, Mong Kok",
              "date": "2024-12-08",
              "dateTimeGMT": "2024-12-08T01:30:00",
              "teams": [
                "Hong Kong Women",
                "China Women"
              ],
              "score": [
                {
                  "r": 100,
                  "w": 7,
                  "o": 20,
                  "inning": "Hong Kong Women Inning 1"
                },
                {
                  "r": 68,
                  "w": 10,
                  "o": 19.2,
                  "inning": "China Women Inning 1"
                }
              ],
              "series_id": "e2f571bd-db63-4a12-ac59-893509cf247b",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "6f5c7f2e-83a4-4746-932b-856cb18c04f5",
              "name": "Hong Kong Women vs Namibia Women, 6th Match",
              "matchType": "t20",
              "status": "Namibia Women won by 4 wkts",
              "venue": "Mission Road Ground, Mong Kok",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T06:00:00",
              "teams": [
                "Hong Kong Women",
                "Namibia Women"
              ],
              "score": [
                {
                  "r": 81,
                  "w": 8,
                  "o": 20,
                  "inning": "Hong Kong Women Inning 1"
                },
                {
                  "r": 82,
                  "w": 6,
                  "o": 19.4,
                  "inning": "Namibia Women Inning 1"
                }
              ],
              "series_id": "e2f571bd-db63-4a12-ac59-893509cf247b",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "cfcb1ac5-c680-49f5-9d2e-55985ceea72b",
              "name": "Thailand Women vs China Women, 5th Match",
              "matchType": "t20",
              "status": "Thailand Women won by 109 runs",
              "venue": "Mission Road Ground, Mong Kok",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T01:30:00",
              "teams": [
                "Thailand Women",
                "China Women"
              ],
              "score": [
                {
                  "r": 117,
                  "w": 9,
                  "o": 20,
                  "inning": "Thailand Women Inning 1"
                },
                {
                  "r": 8,
                  "w": 10,
                  "o": 9.1,
                  "inning": "China Women Inning 1"
                }
              ],
              "series_id": "e2f571bd-db63-4a12-ac59-893509cf247b",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "03513e36-bd05-4741-bee6-0444b81a7e82",
              "name": "Bangladesh U19 vs India U19, Final",
              "matchType": "odi",
              "status": "Bangladesh U19 won by 59 runs",
              "venue": "Dubai International Cricket Stadium, Dubai",
              "date": "2024-12-08",
              "dateTimeGMT": "2024-12-08T05:00:00",
              "teams": [
                "Bangladesh U19",
                "India U19"
              ],
              "score": [
                {
                  "r": 198,
                  "w": 10,
                  "o": 49.1,
                  "inning": "Bangladesh U19 Inning 1"
                },
                {
                  "r": 139,
                  "w": 10,
                  "o": 35.2,
                  "inning": "India U19 Inning 1"
                }
              ],
              "series_id": "4a0e2c59-fd6e-4b65-ac28-63ec0c167b14",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "b467318b-f4f5-4c8f-8efb-7115f82c6d90",
              "name": "Bangladesh Women vs Ireland Women, 2nd T20I",
              "matchType": "t20",
              "status": "Ireland Women won by 47 runs",
              "venue": "Sylhet International Cricket Stadium, Sylhet",
              "date": "2024-12-07",
              "dateTimeGMT": "2024-12-07T08:00:00",
              "teams": [
                "Bangladesh Women",
                "Ireland Women"
              ],
              "score": [
                {
                  "r": 134,
                  "w": 5,
                  "o": 20,
                  "inning": "Ireland Women Inning 1"
                },
                {
                  "r": 87,
                  "w": 10,
                  "o": 17.1,
                  "inning": "Bangladesh Women Inning 1"
                }
              ],
              "series_id": "244963f2-e6b8-4f1a-adf1-7f2714043a52",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "d180496f-43b3-48cc-98a6-7562b73e92cf",
              "name": "Victoria vs Rangpur Riders, Final",
              "matchType": "t20",
              "status": "Rangpur Riders won by 56 runs",
              "venue": "Providence Stadium, Guyana",
              "date": "2024-12-06",
              "dateTimeGMT": "2024-12-06T23:00:00",
              "teams": [
                "Victoria",
                "Rangpur Riders"
              ],
              "score": [
                {
                  "r": 178,
                  "w": 3,
                  "o": 20,
                  "inning": "Rangpur Riders Inning 1"
                },
                {
                  "r": 122,
                  "w": 10,
                  "o": 18.1,
                  "inning": "Victoria Inning 1"
                }
              ],
              "series_id": "8883d72c-2d23-49f2-8b56-fb8c35e4a809",
              "fantasyEnabled": true,
              "bbbEnabled": true,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            },
            {
              "id": "81f5a3a2-06e1-4580-b4cf-a2e0a1a81d0c",
              "name": "Canterbury vs Otago, 12th Match",
              "matchType": "test",
              "status": "Day 2: Stumps - Otago trail by 45 runs",
              "venue": "Mainpower Oval, Rangiora",
              "date": "2024-12-06",
              "dateTimeGMT": "2024-12-06T21:30:00",
              "teams": [
                "Canterbury",
                "Otago"
              ],
              "teamInfo": [
                {
                  "name": "Canterbury",
                  "shortname": "CAN",
                  "img": "https://g.cricapi.com/iapi/15-637993523929449827.webp?w=48"
                },
                {
                  "name": "Otago",
                  "shortname": "OTG",
                  "img": "https://g.cricapi.com/iapi/65-637992667637799448.webp?w=48"
                }
              ],
              "score": [
                {
                  "r": 117,
                  "w": 10,
                  "o": 37.5,
                  "inning": "Otago Inning 1"
                },
                {
                  "r": 331,
                  "w": 10,
                  "o": 96,
                  "inning": "Canterbury Inning 1"
                },
                {
                  "r": 169,
                  "w": 6,
                  "o": 55,
                  "inning": "Otago Inning 2"
                }
              ],
              "series_id": "c8cf5661-3802-4e85-b8f7-5a05e8518e01",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": false
            },
            {
              "id": "ad507d20-9e37-4e0d-88cc-2844759d40be",
              "name": "Northern Knights vs Central Districts, 11th Match",
              "matchType": "test",
              "status": "Day 2: Stumps - Northern Knights trail by 164 runs",
              "venue": "Bay Oval, Mount Maunganui",
              "date": "2024-12-06",
              "dateTimeGMT": "2024-12-06T21:30:00",
              "teams": [
                "Northern Knights",
                "Central Districts"
              ],
              "teamInfo": [
                {
                  "name": "Central Districts",
                  "shortname": "CD",
                  "img": "https://g.cricapi.com/iapi/16-637993517837161031.webp?w=48"
                },
                {
                  "name": "Northern Knights",
                  "shortname": "NK",
                  "img": "https://g.cricapi.com/iapi/62-637992668006396208.webp?w=48"
                }
              ],
              "score": [
                {
                  "r": 204,
                  "w": 10,
                  "o": 59,
                  "inning": "Northern Knights Inning 1"
                },
                {
                  "r": 391,
                  "w": 10,
                  "o": 115.3,
                  "inning": "Central Districts Inning 1"
                },
                {
                  "r": 23,
                  "w": 0,
                  "o": 15,
                  "inning": "Northern Knights Inning 2"
                }
              ],
              "series_id": "c8cf5661-3802-4e85-b8f7-5a05e8518e01",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": false
            },
            {
              "id": "44c98084-b81e-42f2-a576-e10644000bbd",
              "name": "Auckland vs Wellington, 10th Match",
              "matchType": "test",
              "status": "Day 2: Stumps - Wellington trail by 11 runs",
              "venue": "Eden Park Outer Oval, Auckland",
              "date": "2024-12-06",
              "dateTimeGMT": "2024-12-06T21:30:00",
              "teams": [
                "Auckland",
                "Wellington"
              ],
              "teamInfo": [
                {
                  "name": "Auckland",
                  "shortname": "AKL",
                  "img": "https://g.cricapi.com/iapi/5-637993557414710285.webp?w=48"
                },
                {
                  "name": "Wellington",
                  "shortname": "WEL",
                  "img": "https://g.cricapi.com/iapi/99-637987556014883021.webp?w=48"
                }
              ],
              "score": [
                {
                  "r": 329,
                  "w": 10,
                  "o": 95.2,
                  "inning": "Auckland Inning 1"
                },
                {
                  "r": 318,
                  "w": 9,
                  "o": 96,
                  "inning": "Wellington Inning 1"
                }
              ],
              "series_id": "c8cf5661-3802-4e85-b8f7-5a05e8518e01",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": false
            },
            {
              "id": "03f6bcb2-8b64-400d-83ed-5bf55d91ca89",
              "name": "Western Province vs Knights, 15th Match",
              "matchType": "test",
              "status": "Day 1: Stumps - Western Province opt to bat",
              "venue": "Newlands, Cape Town",
              "date": "2024-12-06",
              "dateTimeGMT": "2024-12-06T08:00:00",
              "teams": [
                "Western Province",
                "Knights"
              ],
              "teamInfo": [
                {
                  "name": "Knights",
                  "shortname": "KNG",
                  "img": "https://g.cricapi.com/iapi/40-637992688759741358.webp?w=48"
                },
                {
                  "name": "Western Province",
                  "shortname": "WPR",
                  "img": "https://g.cricapi.com/iapi/104-637987555401464222.webp?w=48"
                }
              ],
              "score": [
                {
                  "r": 175,
                  "w": 7,
                  "o": 73,
                  "inning": "Western Province Inning 1"
                }
              ],
              "series_id": "2e3effc5-142a-46ed-a1d7-b6d98541c78c",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": false
            },
            {
              "id": "f9cf6fdd-089f-40c4-a638-463c5542a78c",
              "name": "Border vs Eastern Storm, 10th Match",
              "matchType": "test",
              "status": "Day 3: Stumps - Border lead by 302 runs",
              "venue": "Buffalo Park, East London",
              "date": "2024-12-05",
              "dateTimeGMT": "2024-12-05T08:00:00",
              "teams": [
                "Border",
                "Eastern Storm"
              ],
              "teamInfo": [
                {
                  "name": "Border",
                  "shortname": "BR",
                  "img": "https://h.cricapi.com/img/icon512.png"
                },
                {
                  "name": "Eastern Storm",
                  "shortname": "ESTORM",
                  "img": "https://g.cricapi.com/iapi/22-637992689531725146.webp?w=48"
                }
              ],
              "score": [
                {
                  "r": 514,
                  "w": 10,
                  "o": 134,
                  "inning": "Border Inning 1"
                },
                {
                  "r": 300,
                  "w": 10,
                  "o": 113,
                  "inning": "Eastern Storm Inning 1"
                },
                {
                  "r": 88,
                  "w": 8,
                  "o": 39.3,
                  "inning": "Border Inning 2"
                }
              ],
              "series_id": "07f32ece-bf7e-4c42-9982-a8af91acdc52",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": false
            },
            {
              "id": "0c06e696-7c2b-467f-9b55-1c209f568b63",
              "name": "South Western Districts vs Limpopo, 9th Match",
              "matchType": "test",
              "status": "Day 3: Stumps - Limpopo lead by 170 runs",
              "venue": "Recreation Ground, Oudtshoorn",
              "date": "2024-12-05",
              "dateTimeGMT": "2024-12-05T08:00:00",
              "teams": [
                "South Western Districts",
                "Limpopo"
              ],
              "teamInfo": [
                {
                  "name": "Limpopo",
                  "shortname": "LIMPO",
                  "img": "https://g.cricapi.com/iapi/42-637991993542281273.webp?w=48"
                },
                {
                  "name": "South Western Districts",
                  "shortname": "SWD",
                  "img": "https://g.cricapi.com/iapi/85-637993498736049006.webp?w=48"
                }
              ],
              "score": [
                {
                  "r": 395,
                  "w": 10,
                  "o": 130.2,
                  "inning": "Limpopo Inning 1"
                },
                {
                  "r": 276,
                  "w": 10,
                  "o": 123.4,
                  "inning": "South Western Districts Inning 1"
                },
                {
                  "r": 51,
                  "w": 0,
                  "o": 28,
                  "inning": "Limpopo Inning 2"
                }
              ],
              "series_id": "07f32ece-bf7e-4c42-9982-a8af91acdc52",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": false
            },
            {
              "id": "1d5c56f8-ffd8-4e4d-88b6-ef53fe0a4e10",
              "name": "Tasmania vs South Australia, 18th Match",
              "matchType": "test",
              "status": "Day 3: Stumps - Tasmania need 388 runs",
              "venue": "Bellerive Oval, Hobart",
              "date": "2024-12-05",
              "dateTimeGMT": "2024-12-05T23:30:00",
              "teams": [
                "Tasmania",
                "South Australia"
              ],
              "teamInfo": [
                {
                  "name": "South Australia",
                  "shortname": "SAUS",
                  "img": "https://g.cricapi.com/iapi/84-637993500332119314.webp?w=48"
                },
                {
                  "name": "Tasmania",
                  "shortname": "TAS",
                  "img": "https://g.cricapi.com/iapi/88-637987559070396403.webp?w=48"
                }
              ],
              "score": [
                {
                  "r": 398,
                  "w": 6,
                  "o": 108,
                  "inning": "South Australia Inning 1"
                },
                {
                  "r": 203,
                  "w": 10,
                  "o": 68.1,
                  "inning": "Tasmania Inning 1"
                },
                {
                  "r": 233,
                  "w": 9,
                  "o": 55,
                  "inning": "South Australia Inning 2"
                },
                {
                  "r": 41,
                  "w": 1,
                  "o": 9,
                  "inning": "Tasmania Inning 2"
                }
              ],
              "series_id": "0a25b3fb-3fc9-4c22-b11b-a30defda74f2",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": false
            },
            {
              "id": "defe827f-a6e4-4d97-b355-f43caffe0f23",
              "name": "Victoria vs Queensland, 17th Match",
              "matchType": "test",
              "status": "Queensland won by 23 runs",
              "venue": "Melbourne Cricket Ground, Melbourne",
              "date": "2024-12-05",
              "dateTimeGMT": "2024-12-05T23:30:00",
              "teams": [
                "Victoria",
                "Queensland"
              ],
              "teamInfo": [
                {
                  "name": "Queensland",
                  "shortname": "QL",
                  "img": "https://g.cricapi.com/iapi/73-637992667453177840.webp?w=48"
                },
                {
                  "name": "Victoria",
                  "shortname": "VIC",
                  "img": "https://g.cricapi.com/iapi/96-637987557199223762.webp?w=48"
                }
              ],
              "score": [
                {
                  "r": 172,
                  "w": 10,
                  "o": 54.3,
                  "inning": "Queensland Inning 1"
                },
                {
                  "r": 123,
                  "w": 10,
                  "o": 54,
                  "inning": "Victoria Inning 1"
                },
                {
                  "r": 223,
                  "w": 10,
                  "o": 69.4,
                  "inning": "Queensland Inning 2"
                },
                {
                  "r": 249,
                  "w": 10,
                  "o": 89.5,
                  "inning": "Victoria Inning 2"
                }
              ],
              "series_id": "0a25b3fb-3fc9-4c22-b11b-a30defda74f2",
              "fantasyEnabled": true,
              "bbbEnabled": false,
              "hasSquad": true,
              "matchStarted": true,
              "matchEnded": true
            }
          ],
          "status": "success",
          "info": {
            "hitsToday": 2,
            "hitsUsed": 1,
            "hitsLimit": 100,
            "credits": 0,
            "server": 14,
            "offsetRows": 0,
            "totalRows": 47,
            "queryTime": 31.4312,
            "s": 0,
            "cache": 0
          }
        }
        """
    
    init() {
            loadMatches() // Load matches immediately on initialization
        }
        
        func loadMatches() {
            do {
                let decoder = JSONDecoder()
                // Add custom date decoding strategy
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    formatter.timeZone = TimeZone(abbreviation: "GMT")
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                // Add snake_case to camelCase conversion
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let apiResponse = try decoder.decode(APIResponse.self, from: Data(self.staticAPIResponse.utf8))
                self.matches = apiResponse.data
                // Clear error message if decoding succeeds
                self.errorMessage = nil
            } catch {
                self.handleError(error)
                // Print detailed error information for debugging
                print("Decoding error: \(error)")
            }
        }
        
        private func handleError(_ error: Error) {
            errorMessage = "An error occurred: \(error.localizedDescription)"
            // Print the full error for debugging
            print("Full error: \(error)")
        }
    }


// End of file. No additional code.
