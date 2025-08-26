//
//  MovieResponse.swift
//  MovieTMDB
//
//  Created by Jorge Ramos on 26/08/25.
//
import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
