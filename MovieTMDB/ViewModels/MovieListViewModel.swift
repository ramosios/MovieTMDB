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
    private var currentPage = 1
    var canLoadMorePages = true

    init(genreId: Int, tmdbService: TMDBService = TMDBService()) {
        self.genreId = genreId
        self.tmdbService = tmdbService
    }

    func loadMovies() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        currentPage = 1
        canLoadMorePages = true

        do {
            let fetchedMovies = try await tmdbService.fetchMovies(forGenre: genreId, page: currentPage)
            if fetchedMovies.isEmpty {
                canLoadMorePages = false
            }
            self.movies = fetchedMovies
        } catch {
            errorMessage = "Failed to load movies: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadMoreMovies() async {
        guard !isLoading && canLoadMorePages else { return }

        isLoading = true
        currentPage += 1

        do {
            let newMovies = try await tmdbService.fetchMovies(forGenre: genreId, page: currentPage)
            if newMovies.isEmpty {
                canLoadMorePages = false
            } else {
                // Filter out movies that are already in the list to prevent duplicates
                let existingMovieIDs = Set(self.movies.map { $0.id })
                let uniqueNewMovies = newMovies.filter { !existingMovieIDs.contains($0.id) }
                self.movies.append(contentsOf: uniqueNewMovies)
            }
        } catch {
            errorMessage = "Failed to load more movies: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
