//
//  MovieError.swift
//  TMDb-Movie-app
//
//  Created by Bugra's Mac on 30.09.2020.
//

import Foundation

enum HomeError: Error {
    
    case apiError
    
    var localizedDescription : String {
        switch self {
        case .apiError: return "Error Occured While Fetching The Data"
        }
    }
    
}
