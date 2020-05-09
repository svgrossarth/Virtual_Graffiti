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

class EmojiViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    var delegate : ChangeEmojiDelegate?

    var Models = [Emoji]()
    var recentModels = [Emoji]()
    var filteredModels:[Emoji] = []
    var selectedEmoji = Emoji(name: "bandage", ID: "Group50555")
    private var selectedModelIndex = 0

    @IBOutlet weak var MenuCollection: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        setupEmojiModels()
        setupRecentModels()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func doneButtonTap(_ sender: Any) {
        print("emoji menu dismissed")
        self.dismiss(animated: true, completion: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo
        let keyboardFrame: NSValue = userInfo?.removeValue(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardHeight = keyboardFrame.cgRectValue.height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let newYOrigin = CGFloat(-keyboardHeight) // or whatever new value you want
            self.view.frame.origin.y = newYOrigin
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let newYOrigin = CGFloat(0) // or whatever new value you want
            self.view.frame.origin.y = newYOrigin
        }
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
        filteredModels = Models
    }

    func setupRecentModels(){
        recentModels.append(Emoji(name:"bandage", ID:"Group50555" ))
        recentModels.append(Emoji(name:"tired", ID:"Group3677"))
        recentModels.append(Emoji(name:"very happy", ID:"Group19895"))
    }

    //MARK: - collectionView

    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if section == 1{
                return filteredModels.count
            }else{
                recentModels = delegate!.getUpdatedList()
                if recentModels.count < 5 {
                    return recentModels.count
                }
                    return 5
            }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let recentCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Menu Cell", for: indexPath) as! MenuCollectionViewCell

            let modelName = recentModels[indexPath.item].name
            if let image = UIImage(named: "\(modelName)"){
                            recentCell.ModelImage.image = image
            }
            return recentCell
        }
            let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Menu Cell", for: indexPath) as! MenuCollectionViewCell
            let modelName = filteredModels[indexPath.item].name
            if let image = UIImage(named: "\(modelName)") {
                menuCell.ModelImage.image = image
            }
        return menuCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: view.frame.width/8, height: view.frame.width/8)
    }

    func collectionView(collecitonView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        print(section)
        if section == 1{
            return Models.count
        }
        return recentModels.count
    }

 //section header view
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print("set height")
        return CGSize(width: self.view.frame.width, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader{
            if indexPath.section == 0 {
                let recentHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ListHeaderView", for: indexPath) as! ListHeaderView
                recentHeader.listHeaderTitle = "RECENTLY USED"

                return recentHeader
            }
            let listHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ListHeaderView", for: indexPath) as! ListHeaderView
            listHeader.listHeaderTitle = "EMOJIS"

            return listHeader
        }
        fatalError("no header")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmoji = recentModels[indexPath.item]
        } else{
            selectedEmoji = filteredModels[indexPath.item]
        }
        delegate?.changeEmoji(emoji: selectedEmoji)
        self.dismiss(animated: true, completion: nil)
    }


    //MARK: - search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredModels = Models
            MenuCollection.reloadData()
            print(recentModels.count)
            return
        }
        filteredModels = Models.filter({ emo -> Bool in emo.name.lowercased().contains(searchText.lowercased())})
        MenuCollection.reloadData()
    }
}
