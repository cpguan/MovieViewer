//
//  MovieViewController.swift
//  MovieViewer
//
//  Created by Pan Guan on 1/29/17.
//  Copyright © 2017 Pan Guan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var endpoint: String = ""
    var filteredDate: [NSDictionary]?
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        
        searchBar.placeholder = "Enter movie title"
        searchBar.delegate = self
        
        loadData()
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)

    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        loadData()
        refreshControl.endRefreshing()
        
    }
    
    func loadData() {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.filteredDate = self.movies
                    
                    self.tableView.reloadData()
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                }
            }
        }
        task.resume()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredDate = filteredDate {
           return filteredDate.count
        } else {
           return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell" , for: indexPath) as! MovieCell
        
        let movie = filteredDate![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "https://image.tmdb.org/t/p/w500/"
        
        if let posterPath = movie["poster_path"] as? String{
             let imageUrl = NSURL(string: baseUrl + posterPath)
             cell.posterView.setImageWith(imageUrl as! URL)
        }
        
        cell.titleLable.text = title
        cell.overviewLable.text = overview
        
        
        print("row \(indexPath.row)")
        return cell
    }
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        filteredDate = searchText.isEmpty ? movies : movies?.filter { (movie: NSDictionary) -> Bool in
         
        // If dataItem matches the searchText, return true to include it
            return (movie["title"] as! String).range(of: searchText, options: .caseInsensitive) != nil
        }
        tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("prepare for segue called")
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
