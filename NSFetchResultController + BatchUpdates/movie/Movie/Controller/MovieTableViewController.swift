//
//  MovieTableViewController.swift
//  Movie
//
//  Created by Ashish Jaiswal on 13/07/22.
//  Copyright © 2022 devhubs. All rights reserved.
//

import UIKit
import CoreData

class MovieTableViewController: UITableViewController {

    private var coreData = CoreDataStack()
    private var fetchedResultontroller: NSFetchedResultsController<Movie>?
    private var movieService: MovieService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieService = MovieService(manageObjectContext: coreData.persistentContainer.viewContext)
        loadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let sections = fetchedResultontroller?.sections {
            return sections.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultontroller?.sections {
            return sections[section].numberOfObjects
            
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultontroller?.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let movieToDelete = fetchedResultontroller?.object(at: indexPath) else {
                return
            }
            let confirmAlertController = UIAlertController(title: "Remove Movie", message: "Are you sure you would like to delete\(movieToDelete.title ?? "")", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { [weak self] (action: UIAlertAction) in
                self?.coreData.persistentContainer.viewContext.delete(movieToDelete)
                self?.coreData.saveContext()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            confirmAlertController.addAction(deleteAction)
            confirmAlertController.addAction(cancelAction)
            present(confirmAlertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        if let movie = fetchedResultontroller?.object(at: indexPath) {
            cell.configureCell(movie: movie)
            cell.userRatingHandler = { [weak self] (newRating) in
                //Movie service to update rating
                self?.movieService?.updateRating(for: movie, with: newRating)
            }
        }
        return cell
    }
    
    private func loadData() {
        fetchedResultontroller = movieService?.getMovies()
        fetchedResultontroller?.delegate = self
    }

    @IBAction func resetRating(_ sender: UIBarButtonItem) {
        movieService?.resetAllRating(completion: {[weak self] succes in
            if succes {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
    }
    
}

extension MovieTableViewController:NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
   
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let indexPath = indexPath  else {
            return
        }
        
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
