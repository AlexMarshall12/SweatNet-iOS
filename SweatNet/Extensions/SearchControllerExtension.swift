//
//  File.swift
//  SweatNet
//
//  Created by Alex on 7/15/18.
//  Copyright © 2018 SweatNet. All rights reserved.
//

//import Foundation
//import UIKit
//class SearchBarEmbedInNavBarViewController: SearchControllerBaseViewController {
//    // MARK: - Properties
//    
//    // `searchController` is set in viewDidLoad(_:).
//    var searchController: UISearchController!
//    
//    // MARK: - View Life Cycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Create the search results view controller and use it for the `UISearchController`.
//        if let searchResultsViewController =
//            storyboard!.instantiateViewController(withIdentifier: SearchResultsViewController.identifier)
//                as? SearchResultsViewController {
//            
//            // Create the search controller and make it perform the results updating.
//            searchController = UISearchController(searchResultsController: searchResultsViewController)
//            searchController.searchResultsUpdater = searchResultsViewController
//        }
//        searchController.hidesNavigationBarDuringPresentation = false
//        navigationItem.hidesSearchBarWhenScrolling = false
//        
//        /** Configure the search controller's search bar. For more information on how to configure
//         search bars, see the "Search Bar" group under "Search".
//         */
//        searchController.searchBar.searchBarStyle = .minimal
//        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "")
//        
//        // Include the search bar within the navigation bar.
//        navigationItem.searchController = searchController
//        
//        definesPresentationContext = true
//    }
//    
//}
