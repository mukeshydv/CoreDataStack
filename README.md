# CoreDataStack
CoreDataStack in Swift


## Repository Usage:
### Create repository:
To create a `Repository` Object:

```swift
let repository = Repository<User>()
```
Here `User` is a subclass of `NSManagedObject`.

### To insert new row
To create new object use the method `create(in:with:)` as follows:

```swift
let user: User = repository.create { (user) in
    user.id = 2
    user.name = "Test User"
}
```
By default `Repository` class use `writeContext` of `CoreDataStack`, alternatively you can pass your own context. Like:

```swift
let user: User = repository.create(in: CoreDataStack.shared.mainContext) { (user) in
    user.id = 2
    user.name = "Test User"
}
```

### To fetch data from an Entity
To fetch the data use the method `fetch(with:in:)`.

#### Fetching all results:
```swift
let users: [User] = try repository.fetch()
```
#### Fetching with predicate:
```swift
let predicate = NSPredicate(format: "name like '*3'")
let users: [User] = try repository.fetch(with: predicate)
```

### To delete object from Entity:
To delete the rows from an entity use `delete(entity:in:)` or `delete(entities:in:)` or `delete(in:with:in: )` methods.

#### Delete single object:
```swift
repository.delete(entity: object)
```
or
```swift
repository.delete(entity: object, in: CoreDataStack.shared.mainContext)
```
#### Delete multiple objects:
```swift
repository.delete(entities: objects)
```
or
```swift
repository.delete(entities: objects, in: CoreDataStack.shared.mainContext)
```

#### Delete multiple objects with predicate:
Here you have to pass the Type of Entity from which you want to delete data.
```swift
let predicate = NSPredicate(format: "name like '*3'")
try repository.delete(in: User.self, with: predicate)
```
or

```swift
let predicate = NSPredicate(format: "name like '*3'")
try repository.delete(in: User.self, with: predicate, in: CoreDataStack.shared.mainContext)
```
