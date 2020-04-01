

import UIKit
import SceneKit

class EmojiContentTableViewController: UITableViewController{

    // Array containing the name of all the 3d models and their images
    private let modelsName = ["very happy", "tired", "thinking", "thermometer", "scream", "dissapointed relieved", "rolling eyes", "poo", "phantom", "nerd", "monkey mouth", "monkey eyes", "monkey ears", "money", "medical mask", "inverted", "hugging", "fearful", "demon", "demon angry", "cry", "close mouth", "bandage", "yum"]
    // To keep the track of selected cell in tableView
    var filteredModelName:[String] = []
    let searchController = UISearchController(searchResultsController: nil)
    private var selectedModelIndex = 0


    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search Emojis"
        definesPresentationContext = true

        // To register the tableView custom cell
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "modelDetailCell")
    }

    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
    }
    // MARK: - TableView DataSource Methods
    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return modelsName.count
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if isFiltering() {
//         searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: modelsName.count)
         return filteredModelName.count
       }

//       searchFooter.setNotFiltering()
       return modelsName.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Making the cell with appropriate information
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelDetailCell", for: indexPath) as! DetailTableViewCell
        let modelName = modelsName[indexPath.row]
        cell.modelTitleLabel.text = modelName.capitalized
        if let image = UIImage(named: "\(modelName)") {
             cell.modelImageView.image = image
        }
        return cell
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Deselecting the selected cell
//        tableView.deselectRow(at: indexPath, animated: true)
//        // Storing the index path of the selected cell
//        selectedModelIndex = indexPath.row
//        
//        // Making the instance of Quick Look Controller, Setting its data source and delegate, and presenting it
////        let previewController = QLPreviewController()
////        previewController.dataSource = self
////        previewController.delegate = self
////        present(previewController, animated: true)
//    }
    
    // MARK:- ARQuickLook DataSource Methods
    
//    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//        return 1
//    }
//
//    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//        // Getting the URL or path of the selected 3d model which will be of type .usdz
//        let url = Bundle.main.url(forResource: modelsName[selectedModelIndex], withExtension: "usdz")!
//        // Returning the url as Preview Item to be displayed by the Quick Look
//        return url as QLPreviewItem
//    }

//    func loadModel() ->SCNReferenceNode{
//        guard  let url = Bundle.main.url(forResource: modelsName[selectedModelIndex], withExtension: "usdz") else {
//            print(modelsName[selectedModelIndex], ".usdz not exit.")
//            fatalError()
//        }
//        guard let customNode = SCNReferenceNode(url: url) else {
//                        fatalError("load model error.")
//        }
//        return customNode
//    }

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "showDetail" {
        if let indexPath = tableView.indexPathForSelectedRow {
          let selectedModel = modelsName[indexPath.row]
          let controller = (segue.destination as! UINavigationController).topViewController as! EmojiScnController
          controller.name = selectedModel
//          controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//          controller.navigationItem.leftItemsSupplementBackButton = true
        }
      }
    }

    // MARK: - Private instance methods

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
      filteredModelName = modelsName.filter({(modle) -> Bool in
        if searchBarIsEmpty() {
          return true
        } else {
          return modle.lowercased().contains(searchText.lowercased())
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
}

extension EmojiContentTableViewController: UISearchBarDelegate {
  // MARK: - UISearchBar Delegate
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    print("for search: ", searchBar.text!)
    filterContentForSearchText(searchBar.text!)
  }
}

extension EmojiContentTableViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
//    print("search bar touched:", searchBar.selectedScopeButtonIndex, "  ", searchController.searchBar.text)
//    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    filterContentForSearchText(searchController.searchBar.text!)
  }
}
