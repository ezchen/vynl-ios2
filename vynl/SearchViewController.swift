//
//  SearchViewController.swift
//  vynl
//
//  Created by Eric Chen on 7/25/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

protocol DefaultModalDelegate {
    func dismissCalled()
}

class SearchViewController: VynlDefaultViewController {
    
    var youtubeHelper: YoutubeDataHelper!
    var songs: [[String: AnyObject]]!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func closePressed(sender: AnyObject) {
        self.delegate?.dismissCalled()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songs = []
        youtubeHelper = YoutubeDataHelper()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as! UISearchTableViewCell
        cell.configureCell(songs[indexPath.row])
        cell.songManager = self.songManager
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        func success(json: AnyObject) {
            self.songs = json as! [[String: AnyObject]]
            self.tableView.reloadData()
            print(self.songs)
        }
        func error(error: AnyObject) {
            SweetAlert().showAlert("Search Failed", subTitle: "Check Your Internet Connection!", style: AlertStyle.Error)
        }
        youtubeHelper.search(searchBar.text!, pageToken: nil, resultsPerPage: 10, success: success, error: error)
        searchBar.resignFirstResponder()
    }
}
