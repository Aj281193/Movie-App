//
//  MovieService.swift
//  Movie
//
//  Created by Ashish Jaiswal on 13/07/22.
//  Copyright © 2022 devhubs. All rights reserved.
//

import Foundation
import CoreData

class MovieService {
    
    private var manageObjectContext: NSManagedObjectContext
    
    init(manageObjectContext: NSManagedObjectContext) {
        self.manageObjectContext = manageObjectContext
    }
    
   func getMovies() -> NSFetchedResultsController<Movie> {
        let fetchedResultContainer: NSFetchedResultsController<Movie>
        
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let formatSort = NSSortDescriptor(key: "format", ascending: true)
        let nameSort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [formatSort,nameSort]
        
        fetchedResultContainer = NSFetchedResultsController(fetchRequest: request, managedObjectContext: manageObjectContext, sectionNameKeyPath: "format", cacheName: "MovieLibrary")
        
        do {
            try fetchedResultContainer.performFetch()
        } catch  {
            fatalError("Error in fetching records")
        }
        return fetchedResultContainer
    }
    
    func updateRating(for movie: Movie, with newRating: Int) {
        movie.userRating = Int16(newRating)
        
        do {
            try manageObjectContext.save()
        } catch  {
            print("error")
        }
    }
    func resetAllRating(completion: (Bool) -> Void) {
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Movie")
        batchUpdateRequest.propertiesToUpdate = ["userRating": 0]
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        do {
            if let batchUpdateResult = try manageObjectContext.execute(batchUpdateRequest) as? NSBatchUpdateResult {
                if let objectIds = batchUpdateResult.result as? [NSManagedObjectID] {
                    for objectId in objectIds {
                        let managedObject = manageObjectContext.object(with: objectId)
                        
                        if !managedObject.isFault {
                            manageObjectContext.stalenessInterval = 0
                            manageObjectContext.refresh(managedObject, mergeChanges: true)
                        }
                    }
                    completion(true)
                }
            }
        } catch {
            completion(false)
        }
    }
}
