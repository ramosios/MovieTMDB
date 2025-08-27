//
//  MovieListViewModel.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 26/08/25.
//
import Foundation

@MainActor
class MoviesListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let tmdbService: TMDBService
    private let genreId: Int

    init(genreId: Int, tmdbService: TMDBService = TMDBService()) {
        self.genreId = genreId
        self.tmdbService = tmdbService
    }

    func loadMovies() async {
        isLoading = true
        errorMessage = nil
        movies.removeAll()

        do {
            let stream = tmdbService.moviesStream(forGenre: genreId)
            for try await movie in stream {
                movies.append(movie)
            }
        } catch {
            errorMessage = "Failed to load movies: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
