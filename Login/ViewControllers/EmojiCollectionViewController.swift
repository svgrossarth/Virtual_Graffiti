//
//  EmojiCollectionViewController.swift
//  Login
//
//  Created by Scarlett Fan on 4/20/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//
//emoji token from https://emojiisland.com/pages/download-new-emoji-icons-in-png-ios-10
import UIKit

private let reuseIdentifier = "Cell"

class EmojiCollectionViewController: UICollectionViewController, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout {

    var Models = [Emoji]()
    var filteredModelName:[Emoji] = []
    var selectedEmoji = Emoji(name: "bandage", ID: "Group50555")
    let searchController = UISearchController(searchResultsController: nil)
    private var selectedModelIndex = 0


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

    func setupSearchBar(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.barTintColor = .lightGray
        collectionView.addSubview(searchController.searchBar)
        searchController.searchBar.placeholder = "Search Emojis"
        definesPresentationContext = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEmojiList()
        // Setup the Search Controller
        setupSearchBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return Models.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath) as! EmojiCollectionViewCell
            let modelName = Models[indexPath.item].name
            if let image = UIImage(named: "\(modelName)") {
                cell.ModelImage.image = image
            }

        return cell
    }

    //MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
       return CGSize(width: 60, height: 60)
    }

    //MARK: search
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        //    print("search bar touched:", searchBar.selectedScopeButtonIndex, "  ", searchController.searchBar.text)
        //    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
//        filterContentForSearchText(searchController.searchBar.text!)
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(Models[indexPath.item].name)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

