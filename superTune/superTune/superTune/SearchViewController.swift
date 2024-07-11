/*//
//  ViewController.swift
//  storeSearch
//
//  Created by MacUser on 2024-07-02.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchResults = [SearchResult]()
    var hasSearched = false


    
    override func viewDidLoad() {
        searchBar.becomeFirstResponder()
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        let cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SearchResultCell")


        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
      }
    }
    // MARK: - Helper Methods
    func iTunesURL(searchText: String) -> URL {
      let encodedText = searchText.addingPercentEncoding(
          withAllowedCharacters: CharacterSet.urlQueryAllowed)!  // Add this
      let urlString = String(
        format: "https://itunes.apple.com/search?term=%@",
        encodedText)                                             // Change this
      let url = URL(string: urlString)
      return url!
    }
    func parse(data: Data) -> [SearchResult] {
      do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(
          ResultArray.self, from: data)
        return result.results
      } catch {
        print("JSON Error: \(error)")
        return []
      }
    }

    func performStoreRequest(with url: URL) -> Data? {
      do {
       return try Data(contentsOf: url)
      } catch {
       print("Download Error: \(error.localizedDescription)")
       return nil
      }
    }


}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      if !searchBar.text!.isEmpty {
        searchBar.resignFirstResponder()

        hasSearched = true
        searchResults = []

        let url = iTunesURL(searchText: searchBar.text!)
        print("URL: '\(url)'")
          if let data = performStoreRequest(with: url) {  // Modified
          let results = parse(data: data)               // New line
          print("Got results: \(results)")              // New line
            }
        tableView.reloadData()
      }
    }
    func position(for bar: any UIBarPositioning) -> UIBarPosition {
        return.topAttached
    }
}
// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
      _ tableView: UITableView,
      numberOfRowsInSection section: Int
    ) -> Int {
      if !hasSearched {
        return 0
      } else if searchResults.count == 0 {
        return 1
      } else {
        return searchResults.count
      }
    }
    func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
      let cellIdentifier = TableView.CellIdentifiers.searchResultCell
      let cell = tableView.dequeueReusableCell(
        withIdentifier: cellIdentifier,
        for: indexPath) as! SearchResultCell                  // Change this
      if searchResults.count == 0 {
        cell.nameLabel.text = "(Nothing found)"               // Change this
        cell.artistNameLabel.text = ""                        // Change this
      } else {
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name               // Change this
        cell.artistNameLabel.text = searchResult.artistName   // Change this
      }
      return cell
    }

    
    func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
    ) {
      tableView.deselectRow(at: indexPath, animated: true)
    }
      
    func tableView(
      _ tableView: UITableView,
      willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
      if searchResults.count == 0 {
        return nil
      } else {
        return indexPath
      }
    }


  }
*/
//
//  ViewController.swift
//  StoreSearch
//
//  Created by Douglas Jasper on 2024-07-02.
//
 
import UIKit
 
class SearchViewController: UIViewController {
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib,
          forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(
          nibName: TableView.CellIdentifiers.loadingCell,
          bundle: nil)
        
        tableView.register(
          cellNib,
          forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        searchBar.becomeFirstResponder()
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed: \(sender.selectedSegmentIndex)")
    }
    // MARK: - Helper Methods
    func iTunesURL(searchText: String) -> URL {
      let encodedText = searchText.addingPercentEncoding(
          withAllowedCharacters: CharacterSet.urlQueryAllowed)!  // Add this
      let urlString = String(format:
        "https://itunes.apple.com/search?term=%@&limit=200",
        encodedText)
                                             // Change this
      let url = URL(string: urlString)
      return url!
    }
    
    func performStoreRequest(with url: URL) -> Data? {
      do {
       return try Data(contentsOf: url)
      } catch {
       print("Download Error: \(error.localizedDescription)")
       showNetworkError()
       return nil
      }
    }
    
    func parse(data: Data) -> [SearchResult] {
      do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(
          ResultArray.self, from: data)
        return result.results
      } catch {
        print("JSON Error: \(error)")
        return []
      }
    }
    
    func showNetworkError() {
      let alert = UIAlertController(
        title: "Whoops...",
        message: "There was an error accessing the iTunes Store." +
        " Please try again.",
        preferredStyle: .alert)
      
      let action = UIAlertAction(
        title: "OK", style: .default, handler: nil)
      alert.addAction(action)
      present(alert, animated: true, completion: nil)
    }
 
 
}
 
// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            // Replace all code after this with new code below
            // 1
            let url = iTunesURL(searchText: searchBar.text!)
             // 2
             let session = URLSession.shared
             // 3
             let dataTask = session.dataTask(with: url) {data, response, error in
               // 4
               if let error = error {
                 print("Failure! \(error.localizedDescription)")
               } else {
                 print("Success! \(response!)")
               }
             }
             // 5
             dataTask.resume()
           }
         }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
      return .topAttached
    }
 
}
 
// MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
      _ tableView: UITableView,
      numberOfRowsInSection section: Int
    ) -> Int {
      if isLoading {
        return 1
      }
      else if !hasSearched { // equivalent to: if hasSearched == false {
        return 0
      } else if searchResults.count == 0 {
        return 1
      } else {
        return searchResults.count
      }
    }
 
 
    func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
      if isLoading {
        let cell = tableView.dequeueReusableCell(
          withIdentifier: TableView.CellIdentifiers.loadingCell,
          for: indexPath)
 
        let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
        spinner.startAnimating()
        return cell
      } else if searchResults.count == 0 {
        return tableView.dequeueReusableCell(
          withIdentifier: TableView.CellIdentifiers.nothingFoundCell,
          for: indexPath)
      } else {
        let cell = tableView.dequeueReusableCell(
          withIdentifier: TableView.CellIdentifiers.searchResultCell,
          for: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty {
          cell.artistNameLabel.text = "Unknown"
        } else {
          cell.artistNameLabel.text = String(
            format: "%@ (%@)",
            searchResult.artist,
            searchResult.type)
        }
        return cell
      }
    }
 
    
    func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
    ) {
      tableView.deselectRow(at: indexPath, animated: true)
    }
      
    func tableView(
      _ tableView: UITableView,
      willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
      if searchResults.count == 0 || isLoading {    // Changed
        return nil
      } else {
        return indexPath
      }
    }
 
 
}

