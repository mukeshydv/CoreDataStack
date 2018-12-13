//
//  Repository.swift
//  CoreDataStack
//
//  Created by Mukesh on 13/12/18.
//  Copyright © 2018 BooEat. All rights reserved.
//

import Foundation
import CoreData

public protocol AbstractRepository {
    associatedtype T: NSManagedObject
    func create(in context: NSManagedObjectContext, with update: (T)->()) -> T
    func fetch(with predicate: NSPredicate?, in context: NSManagedObjectContext) throws -> [T]
    func delete(in entity: T.Type, with predicate: NSPredicate?, in context: NSManagedObjectContext) throws
    func delete(entities: [T], in context: NSManagedObjectContext)
    func delete(entity: T, in context: NSManagedObjectContext)
}

final public class Repository<T: NSManagedObject>: AbstractRepository {
    
    /// Create new managed object for insertion. update the values on the retured object and use `save(context:)` on the same context to insert the row in database.
    ///
    /// - Parameter context: Context on which you're working.
    /// - Returns: returns newly created object.
    @discardableResult
    public func create(in context: NSManagedObjectContext = CoreDataStack.shared.writerContext, with update: (T)->()) -> T {
        let entity: T = context.create()
        update(entity)
        CoreDataStack.shared.save(context: context)
        return entity
    }
    
    /// Fetch objects from an entity with given predicate.
    ///
    /// - Parameters:
    ///   - predicate: predicate string.
    ///   - context: Context on which you're working.
    /// - Returns: array of objects fetched.
    public func fetch(with predicate: NSPredicate? = nil, in context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws -> [T] {
        
        let request = NSFetchRequest<T>(entityName: T.className)
        request.predicate = predicate
        
        return try context.fetch(request)
    }
    
    /// Delete all objects with given predicate.
    ///
    /// - Parameters:
    ///   - entity: Entity type from which you want to delete the objects. like: `User.self`.
    ///   - predicate: predicate string.
    ///   - context: context in which you're working.
    public func delete(in entity: T.Type, with predicate: NSPredicate? = nil, in context: NSManagedObjectContext = CoreDataStack.shared.writerContext) throws {
        let results: [T] = try fetch(with: predicate, in: context)
        delete(entities: results, in: context)
    }
    
    /// Delete an object with given managed context.
    ///
    /// - Parameters:
    ///   - entities: objects to be deleted.
    ///   - context: context in which you're working on.
    public func delete(entities: [T], in context: NSManagedObjectContext = CoreDataStack.shared.writerContext) {
        
        for entity in entities {
            context.delete(entity)
        }
        
        CoreDataStack.shared.save(context: context)
    }
    
    /// Delete an object with given managed context.
    ///
    /// - Parameters:
    ///   - object: object to delete.
    ///   - context: context in which you're working on.
    public func delete(entity: T, in context: NSManagedObjectContext = CoreDataStack.shared.writerContext) {
        context.delete(entity)
        CoreDataStack.shared.save(context: context)
    }
}

extension NSManagedObjectContext {
    fileprivate func create<T: NSFetchRequestResult>() -> T {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: T.className, into: self) as? T else {
            fatalError()
        }
        return entity
    }
}

extension NSObjectProtocol {
    fileprivate static var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}
