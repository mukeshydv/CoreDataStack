//
//  CoreData.swift
//  CoreData
//
//  Created by Mukesh Yadav on 14/08/17.
//

import Foundation
import CoreData

public class CoreDataStack {
    
    public let writerContext: NSManagedObjectContext
    
    public static let shared = CoreDataStack()
    
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
    
    private lazy var applicationDocumentsDirectory: URL = {
        
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cadiridris.coreDataTemplate" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: CoreDataStack.modelFileName, withExtension: CoreDataStack.modelFileExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
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
    
    public lazy var mainContext: NSManagedObjectContext = {
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.writerContext
        return mainContext
    }()
    
    // MARK: - Core Data Saving support
    public func saveMainContext() -> Void {
        self.mainContext.perform {
            
            // Save changes in main context.
            self.save(manageObjectContext: self.mainContext)
            
            self.writerContext.perform {
                
                // Save changes on disk.
                self.save(manageObjectContext: self.writerContext)
            }
        }
    }
    
    public func saveWriteContext() {
        writerContext.perform {
            
            // Save changes on disk.
            self.save(manageObjectContext: self.writerContext)
        }
    }
    
    public func save(context: NSManagedObjectContext) {
        if context == mainContext {
            saveMainContext()
        } else if context == writerContext {
            saveWriteContext()
        }
        
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
    
    /// This methods lets you to create new managed object context.
    ///
    /// - Returns: managed object context.
    public func getTemporaryContext() -> NSManagedObjectContext {
        
        let tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        tempContext.parent = self.mainContext
        return tempContext
    }
}
