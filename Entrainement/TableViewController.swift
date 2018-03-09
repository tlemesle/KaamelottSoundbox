//
//  TableViewController.swift
//  Entrainement
//
//  Created by Thibault Lemesle on 08/03/2018.
//  Copyright © 2018 Thibault Lemesle. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    //var data = [String(),String(),String(),String()]
    
    var data = [Any](){
        didSet {
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.searchBar.scopeButtonTitles = ["Titre", "Episode", "Personnage"]
                self.searchBar.delegate = self
                self.filteredData = self.data
                self.tableView.reloadData()
            }
        }
    }
    
    var filteredData: [Any]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        openJson()
        self.filteredData = self.data
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.filteredData.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sound = self.filteredData[indexPath.row] as! [String:String]
        
        /*let character = sound["character"]!
        let episode = sound["episode"]*/
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = sound["title"]
        cell.detailTextLabel?.text = "\(sound["character"]!) \(sound["episode"]!)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sound = self.filteredData[indexPath.row] as! [String:String]

        let file = sound["file"]!
        
        let store = UserDefaults.standard
        store.synchronize()
        
        var dispo : Bool = false
        
        if let storedDict = store.value(forKey: "fr.lemesle.Eval") as! [String: Data]? {
            for (id, value) in storedDict {
                if(id == sound["title"]){
                    print("Dispo en local, je lance l'écoute offline")
                    dispo = true
                    Player.shared.playSound(value)
                }
            }
        }
        if(dispo == false){
            let service = "http://ctexdev.net/arthur/Kaamelott/sound/\(file)"
            
            print(service)
            
            let url = URL(string: service)
            let request = URLRequest(url: url!)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, resp, err) in
                self.download(data: data as Any, id: sound["title"]!)
                print("Fichier pas en local, je lance l'écoute online")
                Player.shared.playSound(data!)
            }
            task.resume()

        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        
        self.filteredData = searchText.isEmpty ? self.data : self.data.filter { (item: Any) -> Bool in
            // If dataItem matches the searchText, return true to include it
            //let rep = item as! [String:String]
            let selectedScope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            var val = ""
            switch selectedScope{
            case "Titre" :
                val = "title"
            case "Episode" :
                val = "episode"
            case "Personnage" :
                val = "character"
            default: break
            }
            return (item as! [String:String])[val]!.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            //print(res)
        }
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.text = ""
        filteredData = data
        self.tableView.reloadData()
    }
    
    @IBAction func openJson() {
        
        let service = "http://ctexdev.net/arthur/Kaamelott/sound/sounds.json"
        
        
        let url = URL(string: service)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        
        //self.tableView.isHidden = true
        //self.wheel.startAnimating()
        
        let task = session.dataTask(with: request) { (data, resp, err) in
            let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
            for index in 0...((json)?.count)!-1{
                let jsonObjects = (json?[index])
                self.data.append(jsonObjects)
            }
            /*print(json as Any)
            self.data = (json! as? [Any])!
            print(self.data)*/
        }
        task.resume()
        //self.tableView.reloadData()
    }
    
    func download(data : Any, id : String) {
            var dictionnary = [String: Data]()
            let store = UserDefaults.standard
            store.synchronize()
            
            if let storedDict = store.value(forKey: "fr.lemesle.Eval") as! [String: Data]? {
                dictionnary = storedDict
            }
            
            dictionnary["\(id)"] = data as? Data
            
            store.set(dictionnary, forKey: "fr.lemesle.Eval")
            store.synchronize()
        
    }


}
