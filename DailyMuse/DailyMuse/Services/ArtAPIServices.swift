//
//  ArtAPIServices.swift
//  DailyMuse
//
//  Created by Aarna Upadhyaya on 11/15/25.
//
import Foundation

// struct for the mood
struct MoodOption: Identifiable {
    let id = UUID()
    let name: String
    let searchTerm: String
}

// translating the words for the actual picker the API uses
let availableMoods = [
    MoodOption(name: "Choose", searchTerm: ""),
    MoodOption(name: "Despair", searchTerm: "sorrow"),
    MoodOption(name: "Love", searchTerm: "romance"),
    MoodOption(name: "Devotion", searchTerm: "faith"),
    MoodOption(name: "Obsession", searchTerm: "desire"),
    MoodOption(name: "Vexed", searchTerm: "storm"),
    MoodOption(name: "Misc", searchTerm: "abstract")
]

// Chicago Museum API
struct ArtResponse: Codable {
    let data: [ArtWork]
}

struct ArtWork: Codable, Identifiable {
    let id: Int
    let title: String
    let artist_display: String?
    let image_id: String?
    
    // full image url
    var imageURL: URL? {
        guard let imageId = image_id else { return nil }
        return URL(string: "https://www.artic.edu/iiif/2/\(imageId)/full/843,/0/default.jpg")
    }
}

// Poetry DBI API
struct Poem: Codable, Identifiable {
    var id: String { title }
    let title: String
    let author: String
    let lines: [String]
}

// Model for the actual App
struct MuseCard: Identifiable {
    let id = UUID()
    var art: ArtWork?
    var poem: Poem?
}

class MuseService {
    
    static let shared = MuseService()
    
    private init() {}
    
    private static func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    static func fetchArt(searchTerm: String) async throws -> [ArtWork] {
        // using chicago api
        guard let url = URL(string: "https://api.artic.edu/api/v1/artworks/search?q=\(searchTerm)&limit=5&fields=id,title,artist_display,image_id") else {
            throw URLError(.badURL)
        }
        
        let response: ArtResponse = try await fetch(url: url)
        // filtering artworks with no image
        return response.data.filter { $0.image_id != nil }
    }

    static func fetchPoems(searchTerm: String) async throws -> [Poem] {
        // using poetry database
        guard let url = URL(string: "https://poetrydb.org/lines/\(searchTerm)") else {
            throw URLError(.badURL)
        }
        //array of poems
        let poems: [Poem] = try await fetch(url: url)
        return Array(poems.prefix(5)) // Limit to 5
    }
}
