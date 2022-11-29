//
//  ViewController.swift
//  MovieChallenge
//
//  Created by Kevin on 11/29/22.
//

import UIKit

class ViewController: UIViewController {
    
    var viewModelWithoutRx: MovieModelWithoutRx?
    var listMovie: [SearchModel] = []
    @IBOutlet weak var lblEmptyMessage: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarView: UISearchBar!
    @IBOutlet weak var lblResult: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
    }
    
    private func setUpUi() {
        self.searchBarView.delegate = self
        self.tableView.backgroundColor = .clear
        tableView.register(MovieTableViewCell.nib, forCellReuseIdentifier: MovieTableViewCell.identifier)
        self.tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableView.automaticDimension
        self.setUpViewModel()
    }
    
    private func setUpViewModel() {
        viewModelWithoutRx = MovieModelWithoutRx(worker: MovieNetWork())
        
        viewModelWithoutRx?.listMovie.bind { [weak self] movies in
            guard let wSelf = self, !movies.isEmpty else {return}
            wSelf.listMovie = movies
        }
        
        viewModelWithoutRx?.responseMovie.bind(listenner: { [weak self] movieResponse in
            guard let wSelf = self,let movies = movieResponse?.Search else {return}
            wSelf.listMovie = movies
            DispatchQueue.main.async {
                wSelf.showEmptyMessage()
                wSelf.lblResult.text = "About \(movieResponse?.totalResults ?? "") results"
                wSelf.tableView.reloadData()
            }
        })
        
        viewModelWithoutRx?.errHanlder.bind(listenner: { [weak self] error in
            guard let wSelf = self,let error = error else {return}
            wSelf.showAlertWithMessage(content: error.localizedDescription)
        })
    }
    
    private func showEmptyMessage() {
        self.tableView.isHidden = listMovie.isEmpty == true
        self.lblResult.text = ""
        self.lblEmptyMessage.isHidden = !listMovie.isEmpty
    }
    
    private func showAlertWithMessage(content: String) {
        let alert = UIAlertController(title: "Notification", message: content, preferredStyle: .alert)
        self.present(alert, animated: true)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listMovie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as? MovieTableViewCell  else {return UITableViewCell()}
        let data = listMovie[indexPath.row]
        cell.bindingData(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = listMovie[indexPath.row]
        guard let url = URL(string: data.Poster ?? "") else {return}
        let vc = DetailScreenVC(nibName: "DetailScreenVC", bundle: .main)
        vc.url = url
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.listMovie = []
            self.showEmptyMessage()
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.reload), object: nil)
            perform(#selector(reload),with: searchBar,afterDelay: 0.5)
        }
    }
    
    @objc func reload() {
        guard let searchText = searchBarView.text?.uppercased() else { return }
        self.viewModelWithoutRx?.performGetMovie(keyWord: searchText)
    }
    
}

