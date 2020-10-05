//
//  NowPlaying.swift
//  MobilliumMovieApp
//
//  Created by Bugra's Mac on 30.09.2020.
//

import Foundation

struct Response: Decodable {
    var page: Int
    var results: [Movie]
    var totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
