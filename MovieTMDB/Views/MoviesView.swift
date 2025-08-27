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


struct MoviePosterView: View {
    let movie: Movie
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: "\(imageBaseURL)\(movie.posterPath ?? "")")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .overlay(ProgressView())
            }
            .aspectRatio(2/3, contentMode: .fit)
            .cornerRadius(8)
            .shadow(radius: 4)

            Text(movie.title)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 32, alignment: .top)
        }
    }
}
