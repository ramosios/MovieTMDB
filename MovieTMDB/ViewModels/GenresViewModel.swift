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

    init(tmdbService: TMDBService = TMDBService()) {
        self.tmdbService = tmdbService
    }

    func loadGenres() async {
        isLoading = true
        errorMessage = nil
        do {
            genres = try await tmdbService.fetchGenres()
        } catch {
            errorMessage = "Failed to load genres: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
