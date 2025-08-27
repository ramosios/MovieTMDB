//
//  GenresViewModel.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 26/08/25.
//
import Foundation

@MainActor
class GenresViewModel: ObservableObject {
    @Published var genres: [Genre] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let tmdbService: TMDBService
    private let userDefaults = UserDefaults.standard
    private let genresCacheKey = "cachedGenres"
    private let genresTimestampKey = "genresCacheTimestamp"
    private let cacheDuration: TimeInterval = 3600 // 1 hour

    init(tmdbService: TMDBService = TMDBService()) {
        self.tmdbService = tmdbService
    }

    func loadGenres() async {
        if loadFromCache() {
            return
        }
        await fetchFromNetwork()
    }

    private func loadFromCache() -> Bool {
        guard let lastFetchDate = userDefaults.object(forKey: genresTimestampKey) as? Date,
              Date().timeIntervalSince(lastFetchDate) < cacheDuration else {
            return false
        }

        guard let cachedData = userDefaults.data(forKey: genresCacheKey),
              let cachedGenres = try? JSONDecoder().decode([Genre].self, from: cachedData) else {
            return false
        }

        self.genres = cachedGenres
        return true
    }

    private func fetchFromNetwork() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedGenres = try await tmdbService.fetchGenres()
            self.genres = fetchedGenres
            saveToCache(genres: fetchedGenres)
        } catch {
            errorMessage = "Failed to load genres: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func saveToCache(genres: [Genre]) {
        if let encodedData = try? JSONEncoder().encode(genres) {
            userDefaults.set(encodedData, forKey: genresCacheKey)
            userDefaults.set(Date(), forKey: genresTimestampKey)
        }
    }
}
