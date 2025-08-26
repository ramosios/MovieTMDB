//
//  GenreView.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 26/08/25.
//
import SwiftUI

struct GenreView: View {
    @StateObject private var viewModel = GenresViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Genres...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.genres) { genre in
                        NavigationLink(destination: MoviesListView(genreId: genre.id, genreName: genre.name)) {
                            Text(genre.name)
                        }
                    }
                }
            }
            .navigationTitle("Genres")
            .onAppear {
                Task {
                    await viewModel.loadGenres()
                }
            }
        }
    }
}

