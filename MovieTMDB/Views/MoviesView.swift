//
//  MoviesView.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 26/08/25.
//
import SwiftUI
struct MoviesListView: View {
    @StateObject private var viewModel: MoviesListViewModel
    private let genreName: String

    init(genreId: Int, genreName: String) {
        _viewModel = StateObject(wrappedValue: MoviesListViewModel(genreId: genreId))
        self.genreName = genreName
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.movies.isEmpty {
                ProgressView("Loading Movies...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(viewModel.movies) { movie in
                    VStack(alignment: .leading) {
                        Text(movie.title)
                            .font(.headline)
                        Text(movie.overview)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
            }
        }
        .navigationTitle(genreName)
        .onAppear {
            Task {
                await viewModel.loadMovies()
            }
        }
    }
}
