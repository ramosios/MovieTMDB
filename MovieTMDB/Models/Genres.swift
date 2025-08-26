//
//  Genres.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 26/08/25.
//
import Foundation

struct GenresResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}
