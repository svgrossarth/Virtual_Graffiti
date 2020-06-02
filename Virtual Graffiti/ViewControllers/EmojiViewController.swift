//
//  EmojiViewController.swift
//  Login
//
//  Created by Scarlett Fan on 4/20/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//
//https://emojiisland.com/pages/download-new-emoji-icons-in-png-ios-10
import UIKit

protocol ChangeEmojiDelegate : class {
    func changeEmoji(emoji: Emoji)
    func getUpdatedList()->[Emoji]
}

class EmojiViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var delegate : ChangeEmojiDelegate!

    var Models = [Emoji]()
    var recentModels = [Emoji]()
    var filteredModels:[Emoji] = []
    var selectedEmoji = Emoji(name: "bandage", ID: "Group50555")
    var emojiVC : EmojiViewController!
    private var selectedModelIndex = 0
    @IBOutlet weak var MenuCollection: UICollectionView!

    static func makeMemeDetailVC(emojiVC: EmojiViewController) -> EmojiViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListVC") as! EmojiViewController
        newViewController.emojiVC = emojiVC
        return newViewController
}

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEmojiModels()
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
// MARK: setup pre-populated emojis for "RECENTLY USED"
    func setupRecentModels(){
        recentModels.append(Emoji(name:"bandage", ID:"Group50555" ))
        recentModels.append(Emoji(name:"tired", ID:"Group3677"))
        recentModels.append(Emoji(name:"very happy", ID:"Group19895"))
    }

    //MARK: - collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 2
    }

  //MARK: section cell nums
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if section == 1{
                return filteredModels.count
            }else{
                if recentModels.isEmpty{
                    setupRecentModels()
                }else{
                    recentModels = delegate.getUpdatedList()
                }
                if recentModels.count < 5 {
                    return recentModels.count
                }
                    return 5
            }
    }

  //MARK: section cell setup
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

  //MARK: section cell nums
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: view.frame.width/8, height: view.frame.width/8)
    }

    func collectionView(collecitonView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if section == 1{
            return Models.count
        }
        return recentModels.count
    }


    //MARK: section header
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
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

  //MARK: section seleciton
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        recentModels = delegate!.getUpdatedList()
        collectionView.reloadData()
        if indexPath.section == 0 {
            selectedEmoji = recentModels[indexPath.item]
        } else{
            selectedEmoji = filteredModels[indexPath.item]
        }
        delegate?.changeEmoji(emoji: selectedEmoji)
    }

}
