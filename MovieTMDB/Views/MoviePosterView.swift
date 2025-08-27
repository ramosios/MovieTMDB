//
//  MoviePosterView.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 27/08/25.
//
import SwiftUI
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

