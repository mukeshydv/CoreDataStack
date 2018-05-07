//
//  CoreData.swift
//  CoreData
//
//  Created by Mukesh Yadav on 14/08/17.
//

import Foundation
import CoreData

class CoreDataStack {
    
    private var writerContext: NSManagedObjectContext
    
    static let shared = CoreDataStack()
    
    // TODO:- Change these properties.
    /// Data model name, change to yours.
    private static let modelFileName = "TestCoreData"
    
    /// mom or momd, change accordingly. `mom` for `xcdatamodel` and `momd` for `xcdatamodeld`.
    private static let modelFileExtension = "momd"
    
    /// Your physical database name.
    private static let dbFileName = "TestDB.sqlite"
    
    private init () {
        writerContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        writerContext.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cadiridris.coreDataTemplate" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: CoreDataStack.modelFileName, withExtension: CoreDataStack.modelFileExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(CoreDataStack.dbFileName)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            NSLog("Unresolved error \(error)")
        }
        
        return coordinator
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.writerContext
        return mainContext
    }()
    
    // MARK: - Core Data Saving support
    func saveMainContext() -> Void {
        self.mainContext.perform {
            
            // Save changes in main context.
            self.save(manageObjectContext: self.mainContext)
            
            self.writerContext.perform {
                
                // Save changes on disk.
                self.save(manageObjectContext: self.writerContext)
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        context.perform {
            self.save(manageObjectContext: context)
            self.saveMainContext()
        }
    }
    
    private func save(manageObjectContext context: NSManagedObjectContext){
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Unresolved error \(error)")
        }
    }
}

extension CoreDataStack {
    
    /// Create new managed object for insertion. update the values on the retured object and use `save(context:)` on the same context to insert the row in database.
    ///
    /// - Parameter context: Context on which you're working.
    /// - Returns: returns newly created object.
    func createObject<T: NSManagedObject>(in context: NSManagedObjectContext) -> T? {
        return NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(T.self), into: context) as? T
    }
    
    /// Fetch objects from an entity with given predicate.
    ///
    /// - Parameters:
    ///   - predicate: predicate string.
    ///   - context: Context on which you're working.
    /// - Returns: array of objects fetched.
    func fetchObjects<T: NSManagedObject>(with predicate: String? = nil, in context: NSManagedObjectContext) -> [T]? {
        
        let fetch = NSFetchRequest<T>(entityName: NSStringFromClass(T.self))
        
        if let predicate = predicate {
            fetch.predicate = NSPredicate(format: predicate)
        }
        
        var result: [T]?
        do {
            result = try context.fetch(fetch)
        } catch {
            print(error)
        }
        
        return result
    }
    
    /// Delete all objects with given predicate.
    ///
    /// - Parameters:
    ///   - entity: Entity type from which you want to delete the objects. like: `User.self`.
    ///   - predicate: predicate string.
    ///   - context: context in which you're working.
    func delete<T: NSManagedObject>(in entity: T.Type, with predicate: String?, in context: NSManagedObjectContext) {
        if let results: [T] = fetchObjects(with: predicate, in: context) {
            for result in results {
                context.delete(result)
            }
            
            CoreDataStack.shared.save(context: context)
        }
    }
    
    /// Delete an object with given managed context.
    ///
    /// - Parameters:
    ///   - object: object to delete.
    ///   - context: context in which you're working on.
    func delete(object: NSManagedObject, in context: NSManagedObjectContext) {
        context.delete(object)
        CoreDataStack.shared.save(context: context)
    }
    
    /// This methods lets you to create new managed object context.
    ///
    /// - Returns: managed object context.
    func getTemporaryContext() -> NSManagedObjectContext {
        
        let tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempContext.parent = self.mainContext
        return tempContext
    }
}




