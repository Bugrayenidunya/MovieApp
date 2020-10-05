//
//  NowPlaying.swift
//  TMDb-Movie-app
//
//  Created by Bugra's Mac on 30.09.2020.
//

import Foundation

struct Response: Decodable {
    
    var results: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case results
    }
    
}
