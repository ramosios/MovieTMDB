//
//  TMDBService.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 26/08/25.
//
import Foundation

class TMDBService {
    private let apiKey = "b129e7c730e4df76d3111fcb5ba8a1ab"
    private let baseURL = "https://api.themoviedb.org/3"
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    func fetchGenres() async throws -> [Genre] {
        let urlString = "\(baseURL)/genre/movie/list?api_key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try decoder.decode(GenresResponse.self, from: data)
            return response.genres
        } catch let error as URLError {
            throw APIError.requestFailed(error)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func moviesStream(forGenre genreId: Int) -> AsyncThrowingStream<Movie, Error> {
        AsyncThrowingStream { continuation in
            Task {
                var currentPage = 1
                var hasMorePages = true

                while hasMorePages {
                    let urlString = "\(baseURL)/discover/movie?api_key=\(apiKey)&with_genres=\(genreId)&page=\(currentPage)"
                    guard let url = URL(string: urlString) else {
                        continuation.finish(throwing: APIError.invalidURL)
                        return
                    }

                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let response = try decoder.decode(MovieResponse.self, from: data)

                        response.results.forEach { continuation.yield($0) }

                        if response.page < response.totalPages {
                            currentPage += 1
                        } else {
                            hasMorePages = false
                        }
                    } catch let error as URLError {
                        continuation.finish(throwing: APIError.requestFailed(error))
                        return
                    } catch {
                        continuation.finish(throwing: APIError.decodingFailed(error))
                        return
                    }
                }
                continuation.finish()
            }
        }
    }
}
enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
}
