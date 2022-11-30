//
//  MovieViewModel.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import Foundation
import RxSwift

protocol MoviePresenter: AnyObject {
    func getMovie(list: [SearchModel])
}

protocol MovieModelWithoutRxProtocol: AnyObject {
    func performGetMovie(keyWord: String)
}

class MovieModelWithoutRx: MovieModelWithoutRxProtocol {
    var listMovie: Handler<[SearchModel]> = Handler([])
    var responseMovie: Handler<MovieResponse?> = Handler(nil)
    var errHanlder: Handler<Error?> = Handler(nil)
    
    private  var worker: MovieNetWorkProtocol
    init(worker: MovieNetWorkProtocol) {
        self.worker = worker
    }
    
    func performGetMovie(keyWord: String) {
        print("keyworld -- \(keyWord)")
        let rootURl = "https://www.omdbapi.com/?s="
        let key = "&apikey=b831f50c"
        let urlStr = rootURl+"\(keyWord)"+key
        guard let url = URL(string: urlStr) else {return}
        let urlRq = URLRequest(url: url)
        worker.getArticle(url: urlRq) { response in
            self.responseMovie.value = response
            guard let listSearch = response.Search else {return}
            self.listMovie.value = listSearch
        } errHandler: { error in
            self.errHanlder.value = error
        }
    }
}
