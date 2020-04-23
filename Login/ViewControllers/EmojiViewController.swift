//
//  EmojiViewController.swift
//  Login
//
//  Created by Scarlett Fan on 4/20/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//
//https://emojiisland.com/pages/download-new-emoji-icons-in-png-ios-10
import UIKit

protocol ChangeEmojiDelegate {
    func changeEmoji(emoji: Emoji)
    func getUpdatedList()->[Emoji]
}

class EmojiViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating {

    var delegate : ChangeEmojiDelegate?

    var Models = [Emoji]()
    var recentModels = [Emoji]()
    var filteredModelName:[Emoji] = []
    var selectedEmoji = Emoji(name: "bandage", ID: "Group50555")
    let searchController = UISearchController(searchResultsController: nil)
    private var selectedModelIndex = 0

    @IBOutlet weak var RecentCollection: UICollectionView!
    @IBOutlet weak var MenuCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupEmojiModels()
        setupRecentModels()

    }

    func setupEmojiModels(){
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
        searchController.searchBar.placeholder = "Search Emojis"
        searchController.searchBar.barTintColor = .darkGray
        self.view.addSubview(searchController.searchBar)
        definesPresentationContext = true
    }

    func setupRecentModels(){
        recentModels.append(Emoji(name:"bandage", ID:"Group50555" ))
        Models.append(Emoji(name:"tired", ID:"Group3677"))
        Models.append(Emoji(name:"very happy", ID:"Group19895"))
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == MenuCollection {
            return Models.count
        }
//        recentModels = delegate?.getUpdatedList() as! [Emoji]
        if recentModels.count == 0 {
            //reset to pre-populated ones
            setupRecentModels()
        }
        if recentModels.count < 5 {
            return recentModels.count
        }
            return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == MenuCollection {

                let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Menu Cell", for: indexPath) as! MenuCollectionViewCell
                let modelName = Models[indexPath.item].name
                if let image = UIImage(named: "\(modelName)") {
                    menuCell.ModelImage.image = image
                }

            return menuCell
        }
        let recentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Recent Cell", for: indexPath) as! RecentCollectionViewCell
        if collectionView == RecentCollection {
            //if has user ->
                //load from database
            //if not->
            let modelName = recentModels[indexPath.item].name
            if let image = UIImage(named: "\(modelName)"){
                       recentCell.RecentModelImage.image = image
            }
        }
        return recentCell
    }

    //section header view

//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let recentHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RecentHeaderView", for: indexPath) as! RecentHeaderView
//        recentHeader.recentHeaderTitle = "recently Used"
//
//        if collectionView == MenuCollection{
//            let listHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ListHeaderView", for: indexPath) as! ListHeaderView
//            listHeader.listHeaderTitle = "all Emojis"
//
//            return listHeader
//        }
//
//
//        return recentHeader
//    }

//
//     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//            return CGSize(width:collectionView.frame.size.width, height:70)
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        Models[indexPath.item].incrementNumSelected()
        selectedEmoji = Models[indexPath.item]
        delegate?.changeEmoji(emoji: selectedEmoji)
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width, height: 70)
    }


    //MARK: search
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
                //    print("search bar touched:", searchBar.selectedScopeButtonIndex, "  ", searchController.searchBar.text)
                //    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        //        filterContentForSearchText(searchController.searchBar.text!)
    }

}
