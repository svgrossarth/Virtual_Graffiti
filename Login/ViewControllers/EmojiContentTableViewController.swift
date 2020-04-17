//
//  EmojiContentTableViewController.swift
//  Login
//
//  Created by Scarlett Fan on 4/16/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//


import UIKit
import SceneKit

class EmojiContentTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating{

    // TODO: need to add Model ID
    var Models = [Emoji]()
    private func setupEmojiList(){
        Models.append(Emoji(name:"bandage", ID:"Group50555" ))
        Models.append(Emoji(name:"close mouth", ID:"Group13488" ))
        Models.append(Emoji(name:"cry", ID:"Group12814" ))
        Models.append(Emoji(name:"angry demon", ID:"Group29239" ))
        Models.append(Emoji(name:"demon", ID:"Group28240"))
        Models.append(Emoji(name:"relieved", ID:"Group64891"))
        Models.append(Emoji(name:"fearful", ID:"Group40013"))
        Models.append(Emoji(name:"hugging", ID:"Group21149"))
        Models.append(Emoji(name:"inverted", ID:"Group8959"))
        Models.append(Emoji(name:"medical mask", ID:"Group27429"))
        Models.append(Emoji(name:"money", ID:"Group30442"))
        Models.append(Emoji(name:"monkey ears", ID:"Group006"))
        Models.append(Emoji(name:"monkey eyes", ID:"Group006"))
        Models.append(Emoji(name:"monkey mouth", ID:"Group006"))
        Models.append(Emoji(name:"nerd", ID:"Group30022"))
        Models.append(Emoji(name:"no mouth", ID:"Group18920"))
        Models.append(Emoji(name:"ghost", ID:"Group33346"))
        Models.append(Emoji(name:"poo", ID:"Group2382"))
        Models.append(Emoji(name:"rolling eyes", ID:"Group13301"))
        Models.append(Emoji(name:"scream", ID:"Group47015"))
        Models.append(Emoji(name:"thermometer", ID:"Group9951"))
        Models.append(Emoji(name:"thinking", ID:"Group41438"))
        Models.append(Emoji(name:"tired", ID:"Group3677"))
        Models.append(Emoji(name:"very happy", ID:"Group19895"))
        Models.append(Emoji(name:"yum", ID:"Group46695"))
    }

    //Array containing the name of all the 3d models and their images
//    let modelsName = ["very happy", "tired", "thinking", "thermometer", "scream", "dissapointed relieved", "rolling eyes", "poo", "phantom", "nerd", "monkey mouth", "monkey eyes", "monkey ears", "money", "medical mask", "inverted", "hugging", "fearful", "demon", "demon angry", "cry", "close mouth", "bandage", "yum"]


    var filteredModelName:[Emoji] = []
    var selectedEmoji = Emoji(name: "bandage", ID: "Group50555")
    let searchController = UISearchController(searchResultsController: nil)
    private var selectedModelIndex = 0


    override func viewDidLoad() {
            super.viewDidLoad()
            setupEmojiList()
            // Setup the Search Controller
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = true
            tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.placeholder = "Search Emojis"
            definesPresentationContext = true

            // To register the tableView custom cell
            tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "modelDetailCell")
    }

    @IBAction func goBack(_ sender: Any) {
      //TODO: for backup choice
    }

    override func didReceiveMemoryWarning() {
         super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
//        self.navigationController?.popViewController(animated: true)
//        pushViewController(vc!, animated: true)
//        self.navigationController?.popToRootViewController(animated: true)
        print("----------------------------------")
//        tableView.deselectRow(at: indexPath, animated: true)
//        self.navigationController?.popToRootViewController(animated: true)
//        performSegue(withIdentifier: "goback", sender: self)

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelDetailCell", for: indexPath) as! DetailTableViewCell
        let modelName = Models[indexPath.row].name
        cell.modelTitleLabel.text = modelName.capitalized
        if let image = UIImage(named: "\(modelName)") {
             cell.modelImageView.image = image
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering() {
//            searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: modelsName.count)
//            return filteredModelName.count
//        }
//          searchFooter.setNotFiltering()
        return Models.count
    }

//MARK: -Segues
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

//        let controller = segue.destination as! HomeViewController
//        if let indexPath = tableView.indexPathForSelectedRow {
//
//            selectedEmoji = Models[indexPath.row]
//            print(selectedEmoji.name)
//            controller.emoji = selectedEmoji
//        }

    }

    //MARK: search functions
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
      filteredModelName = Models.filter({(model) -> Bool in
        if searchBarIsEmpty() {
          return true
        } else {
          return model.name.lowercased().contains(searchText.lowercased())
        }
      })
      tableView.reloadData()
    }

    func searchBarIsEmpty() -> Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
      let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
      return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }

    // MARK: - UISearchBar Delegate
     func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
       print("for search: ", searchBar.text!)
       filterContentForSearchText(searchBar.text!)
     }

     // MARK: - UISearchResultsUpdating Delegate
      func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
    //    print("search bar touched:", searchBar.selectedScopeButtonIndex, "  ", searchController.searchBar.text)
    //    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!)
      }
}

//class Emoji {
//    let name : String
//    let ID :  String
////    let Image_2D : String
//
//    init(name: String, ID: String) {
//        self.name = name
//        self.ID = ID
////        self.Image_2D = name
//    }
//}

