# FlickrPhotos
Simple app for browsing Flickr public photos.

## Main concepts of the project are:
	- modularity 
	- clear object's responsibilities 
	- clear APIs 
	- testability

## Functionality
#### Photo Search screen.
	By default the screen displays recently uploaded public photos. It has a search bar where a user can create a query which will be instantly executed. 

## Design, features and solutions
#### Business logic
- MainInteractor is the main business logic unit, responsible for reacting on events from AppDelegate, switching UI-scenes, creating and storing shared app services and resources

#### UI
- Typical UI unit consist of view controller and it's model. View controller is responsible for managing UI elements inside its view, the model is responsible for providing data to view controller

#### DataLayer + APILayer
- DataService is responsible all the data storing and retrieving. Right now it only communicates to APIClient but potentially there can be the entire layer of local storing/retrieving inside.
- APIClient is responsible for interacting to Flickr API. Currently it uses plain URLSession under the hood. The interaction is implemented via Flickr REST API. JSON serialization exploits Swift Codable functionality.
- DataLayer and APILayer are binded by callback closures because it's one-to-one relation. The ther parts of the app (UI scenes) have to subscribe to notification from DataService to react on data changes because it can be one-to-many relation (several app parts can be interested in the same data model)
