# FlickrPhotos
Simple app for browsing Flickr public photos.

## Main concepts of the project are:
	- modularity 
	- clear object's responsibilities 
	- clear APIs 
	- testability

## Functionality
#### Photo Search Screen.
    By default the screen displays recently uploaded public photos. It has a search bar where a user can create a query which will be instantly executed.
#### Photo Details Screen
    By tapping the photo in Search Screen the user opens Photo Details Screen. There they can see fullscreen photo and some details about it
    
All layouts suppose to properly look on both portrait and landscape modes of iPhone.

Images are cached in a simple local image cache.

## Design, features and solutions
#### Business logic
- MainInteractor is the main business logic unit, responsible for reacting on events from AppDelegate, switching UI-scenes (currently it's only one of them), creating and storing shared app services and resources

#### UI
- Typical UI unit consist of view controller and it's model. View controller is responsible for managing UI elements inside its view, the model is responsible for providing data to view controller

#### DataLayer + APILayer
- DataService is responsible all the data storing and retrieving. Right now it only communicates to APIClient but potentially there can be the entire layer of local storing/retrieving inside.
- DataLayer and APILayer are binded by callback closures because it's one-to-one relation. The ther parts of the app (UI scenes) have to subscribe to notification from DataService to react on data changes because it can be one-to-many relation (several app parts can be interested in the same data model)
- NetworkService is responsible for interacting with remote Flickr API. The interaction is implemented via Flickr REST API. JSON serialization exploits Swift Codable functionality.
- APIClient is an adapter-class responsible for wrapping specific networking API. Currently it uses plain URLSession under the hood, but can be potentially switched to another networking library.

### TODO:
- Image loading via Operations
- Better test coverage
