//
//  TMDBService.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 26/08/25.
//
import Foundation

struct TMDBService {
    private let apiKey = "b129e7c730e4df76d3111fcb5ba8a1ab"
    private let baseURL = "https://api.themoviedb.org/3"
    private let decoder = JSONDecoder()

    func fetchGenres() async throws -> [Genre] {
        let urlString = "\(baseURL)/genre/movie/list?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.requestFailed(NSError(domain: "TMDBService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed"]))
        }

        do {
            let response = try decoder.decode(GenresResponse.self, from: data)
            return response.genres
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func fetchMovies(forGenre genreId: Int, page: Int) async throws -> [Movie] {
        let urlString = "\(baseURL)/discover/movie?api_key=\(apiKey)&with_genres=\(genreId)&page=\(page)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.requestFailed(NSError(domain: "TMDBService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed"]))
        }

        do {
            let response = try decoder.decode(MovieResponse.self, from: data)
            return response.results
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
}
