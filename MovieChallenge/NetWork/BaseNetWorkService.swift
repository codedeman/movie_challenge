//
//  BaseNetWorkService.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import Foundation

typealias ErrHandler = (Error?) -> Void


protocol MovieNetWorkProtocol: AnyObject {
    func getArticle(url: URLRequest , completion: @escaping (MovieResponse)->Void, errHandler: @escaping ErrHandler)
}

class MovieNetWork: MovieNetWorkProtocol {
    func getArticle(url: URLRequest, completion: @escaping (MovieResponse) -> Void, errHandler:@escaping (Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data , resonse , err in
            if let err = err {
                errHandler(err)
            } else {
                do {
                    if let data = data {
                        let obj = try JSONDecoder().decode(MovieResponse.self, from: data)
                        completion(obj)
                    }
                } catch  let err{
                    print(err)
                }
            }
           
        }
        task.resume()
        
    }
    
    
   
    
}
