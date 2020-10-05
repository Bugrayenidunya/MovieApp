//
//  Movie.swift
//  TMDb-Movie-app
//
//  Created by Bugra's Mac on 30.09.2020.
//

import Foundation

struct Movie: Decodable {
    
    var posterPath: String?
    var overview: String?
    var id: Int?
    var originalTitle: String?
    var title: String?
    var popularity: Double?
    var voteCount: Int?
    var voteAverage: Double?
    var releaseDate: String?
    var imdbID: String?
    var tagline: String?
    
    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case overview, tagline, title
        case id
        case originalTitle = "original_title"
        case popularity
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case imdbID = "imdb_id"
    }
    
}
