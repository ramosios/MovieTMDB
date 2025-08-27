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

    private let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    init(genreId: Int, genreName: String) {
        _viewModel = StateObject(wrappedValue: MoviesListViewModel(genreId: genreId))
        self.genreName = genreName
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.movies.isEmpty {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else {
                movieGridView
            }
        }
        .navigationTitle(genreName)
        .onAppear {
            if viewModel.movies.isEmpty {
                Task {
                    await viewModel.loadMovies()
                }
            }
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        ProgressView("Loading Movies...")
    }

    @ViewBuilder
    private func errorView(message: String) -> some View {
        Text(message)
            .foregroundColor(.red)
            .padding()
    }

    @ViewBuilder
    private var movieGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.movies) { movie in
                    MoviePosterView(movie: movie)
                        .onAppear {
                            if movie == viewModel.movies.last {
                                Task {
                                    await viewModel.loadMoreMovies()
                                }
                            }
                        }
                }
            }
            .padding()

            if viewModel.isLoading && !viewModel.movies.isEmpty {
                ProgressView()
                    .padding()
            }
        }
    }
}
