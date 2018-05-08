# CoreDataStack
CoreDataStack in Swift
### To insert new row
To create new object use the method `createObject(in: )` as follows:

```swift
let user: User? = CoreDataStack.shared.createObject(in: CoreDataStack.shared.mainContext)
user?.name = "Test Name"

CoreDataStack.shared.saveMainContext()
```
### To fetch data from an Entity
To fetch the data use the method `fetchObjects(in: )` or `fetchObjects(with: , in: )`.

#### Fetching all results:
```swift
let users: [User]? = CoreDataStack.shared.fetchObjects(in: CoreDataStack.shared.mainContext)
```
#### Fetching with predicate:
```swift
let users: [User]? = CoreDataStack.shared.fetchObjects(with: "name like '*3'", in: CoreDataStack.shared.mainContext)
```

### To delete object from Entity:
To delete the rows from an entity use `delete(object: , in: )` or `delete(in: , with: , in: )` methods.

#### Delete single object:
```swift
CoreDataStack.shared.delete(object: object, in: CoreDataStack.shared.mainContext)
```
#### Delete multiple objects with predicate:
Here you have to pass the Type of Entity from which you want to delete data.
```swift
CoreDataStack.shared.delete(in: User.self, with: "name like '*3'", in: CoreDataStack.shared.mainContext)
```
### Working on background threads
The above examples uses the mainContext provided by CoreDataStack. This context is for main thread, if you wish to access data on any different thread then use the getTemporaryContext() method. The context provided by this method can be used with all the methods in CoreDataStack.
