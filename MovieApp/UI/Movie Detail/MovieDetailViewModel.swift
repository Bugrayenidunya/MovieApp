//
//  MovieDetailViewModel.swift
//  TMDb-Movie-app
//
//  Created by Bugra's Mac on 30.09.2020.
//

import Alamofire

struct MovieDetailViewModel {
    // Get current language of device and call API with that code
    private var language = Locale.current.languageCode
    
    func fetchSimilarMovies(id: Int, completion: @escaping(Swift.Result<Response, MovieDetailError>) -> Void) {
        
        let url = "\(Constant.ApiConstant.baseURL)/movie/\(id)/similar?api_key=\(Constant.ApiConstant.apiKey)&language=\(language ?? "en-US")"
        
        let request = AF.request(url, method: .get)
        
        request.responseDecodable (of: Response.self) { (response) in
            do {
                try completion(Swift.Result.success(response.result.get()))
            } catch {
                print(error)
            }
        }
    }
    
    func fetchMovieDetail(id: Int, completion: @escaping(Swift.Result<Movie, HomeError>) -> Void) {
        
        let url = "\(Constant.ApiConstant.baseURL)/movie/\(id)?api_key=\(Constant.ApiConstant.apiKey)&language=\(language ?? "en-US")"
        
        let request = AF.request(url, method: .get)
        
        request.responseDecodable (of: Movie.self) { (response) in
            do {
                try completion(Swift.Result.success(response.result.get()))
            } catch {
                print(error)
            }
        }
    }
    
}
