### DrawState
This class handles drawing and QR code scanning. Additionally, it interfaces with the Database class to initiate saving drawings to the database and is the final stage of loading objects in the local scene. 
- **detectBarcodeRequest**: Attempts to find a barcode using the Vision API, if one is found processClassification is called to handle the actual barcode.
- **processClassification(for request: VNRequest)**: Initializes the local QRNode based on the position of the barecode and its payload. Additionally, it creates an orange box around the QR Code to indicate that it has been scanned.
- **placeQRNodes(qrNodes : [QRNode])**: This is the callback function after the database retrieves QRNodes from the database. Each QRNode is compared against all current nodes to see if there are duplicates. If the QRNode needs to be placed in the scene it is made a child of the rootOfTheScene.
- **Initialize(_sceneView: SceneLocationView!, userUID: String)**: Initializes the DrawState, first without any need of location information then adding location specific information if it is available. 
- **setupSceneWithLocation()**: Adds location specific information to the scene.
- **replaceRootNode()**: Updates the rootOfTheScene, changing it from a node without location information to one with location information.
- **initUserRootNodeLocation(location: CLLocation)**: Updates the userRootNode, and qrNode if it exists, with location information.
- **initializeUserRootNode()**: Initializes the userRootNode without any location information.
- **_initializeSceneView(_sceneView: SceneLocationView!)**:  Sets up the scene. Starting the process of getting location information.
- **createSphere(position : SCNVector3) -> SCNNode**: Creates a SCNNode in the shape of ball.
- **addLighting() ->SCNLight**: Creates a light.
- **touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)**: Callback function when the user moves their finger. This function builds the currentStroke based on where the user touched. 
- **touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)**: Callback function when the user lifts their finger. Sets a few flags and saves the currentStroke to the database. 
- **placeSingleTapBall(touches: Set<UITouch>)**: When the user taps the screen a ball is placed based on the position of the touch. 
- **touchLocationIn3D (touchLocation2D: CGPoint) -> SCNVector3**: Translates the 2D touch of the user into a 3D position in the screen. 
- **session(_ session: ARSession, didUpdate frame: ARFrame)**: Called each time the session is updated. Makes the initial call to check for a QR Code.  Additionally, checks to see how far the user has moved since they started. If they have moved far, the scene is reset.
- **save()**: Calls the database to save userRootNodes and QRNodes.
- **load(location: CLLocation)**: Loads userRootNodes from the database based on location.
- **checkAndPlaceUserRootNode(newNode : SecondTierRoot)**: When loading userRootNodes from the database this function checks for duplicates that are already in the scene. If a userRootNode needs to be placed in the scene it is placed.
- **deg2rad(_ number: Double) -> Double**: Converts a degree to a radian.

### Stroke 
This class is a SCNNode that contains the geometry of a single stroke of the users finger.
- **init(firstPoint : SCNVector3, color : UIColor, thickness : Float)**: Initializes the stroke with its first point, color and thickness.
- **init?(coder: NSCoder)**: Needed to convert the class to bytes.
- **addVertices(point3D: SCNVector3, initialNearFarLine: SCNVector3, lineBetweenNearFar: SCNVector3)**: Adds vertices to the geometry of the Stroke.
- **connectVertices()**: Index the vertices of the Stroke and connects the past vertices to the new ones. 

### SecondTierRoot
This is the user root node. This is the node that all drawings and emojis are attached to. This class is what is uploaded and downloaded from the database based on location. This abstraction was needed because we need to have several of these in a scene, which is different from the actual root of the scene where this always only one. 
- **init()**: Initializes the node with a location
- **init?(coder: NSCoder)**: Initializer needed to convert to bytes.

### Math
A collection of functions that do some common math operations.
- **crossProduct(vec1: SCNVector3, vec2: SCNVector3) -> SCNVector3**: Returns the cross product of the two vectors.
- **resizeVector(vector: SCNVector3, scalingFactor: Float) -> SCNVector3**: Scales a given vector by a factor.
- **distanceBetweenPoints(vec1: SCNVector3, vec2: SCNVector3) -> Float**: Returns the distance between two 3D points.

### QRNode 
This class is the SCNNode that is created when a QR Code is scanned. The local user root node is made a child of this node. When saving and loading QR related information, this is the class used.
- **init(QRValue: String, name: String)**: Initialized the QRNode with a name and the payload of the QR code. 
- **init?(coder: NSCoder)**: Needed to convert this class to bytes. 

### EditState
This class handles editing of drawings, including erasing stroke,changing pencil color and new features including placing emoji, signing in and signing out.It provides with the User Interface
- **initialize(signoutButton: UIButton, pencilButton: UIButton, menuButton: UIButton, emojiButton: ModeButton, eraseButton: UIButton, distanceSlider : UISlider, distanceLabel : UILabel, drawState : DrawState, refSphere : SCNNode, sceneView : ARSCNView, widthSlider : UISlider, widthLabel : UILabel, userUID: String, undoButton : UIButton, redoButton : UIButton)**: Initialize the EditState, Initialize all buttons needed for editing UI
- **createColorSelector(changeColorButton: UIButton, colorStack: UIStackView)**:initialization for changeColorButton and colorStack
- **enter()**: initial setup for button and sliders when entering EditState
- **exit()**: reset all variables to be default value when exits EditState
- **menuButtonTouched()**: create animation when “menu bar” icon is clicked. Either close drop-down buttons or open up drop down buttons. Closing drop-down animation depends on which functionality mode is on
- **changeColor()**: enable colorStack or disable colorStack and set image for color selction button. Disable eraser and emoji if they are on.
- **pencilButtonTouched()**: enable pencil or disable pencil and set image for pencil button. Disable any other mode
- **eraseButtonTouchUp()**: enable eraser or disable eraser and set image for eraser button. Disable any other mode
- **distanceSliderChange()**: change distance and apply the value to reference Sphere
- **widthSliderChange()**: change width and apply the value to reference Sphere
- **removeSphere()**: modify reference Sphere
- **emojiButtonTouched()**: emoji button is touched and set emoji button. Disable any other mode
- **setModel()**: initial setup for emoji model
- **directionalLighting() ->SCNLight**: lighting setup
- **stateChangeEmoji(emoji: Emoji)**: change current emoji model
- **setupRecentList()**: initial setup for prePopEmoji for recently used emoji models
- **updateRecentEmojiList()**: update recently used emoji model list
- **degToRadians(degrees:Double) -> Double**: mathematical conversion from degree to radius
- **touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)**: Callback function when the user put their finger on the screen. This function enables placing emoji or erasing drawings
- **touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)**: Callback function when the user moves their finger. This function allows erasing based on touches
- **eraseNode(touches: Set<UITouch>)**: function to erase user-specific stroke or emoji from userRootNode and from database based on UID.
- **undoErase()**: function for undo erasing. Adding previous erased node back to userRootNode and to database
- **redoErase()**: function for redo erasing. Removing previous erased but undo-erased node from userRootNode and to database
- **changeRedoVisability()**: redo button UI. Make redo button visible or not depends on undo erasing action
- **changeUndoVisability()**: undo button UI. Make undo button visible or not depends on erasing action

### EmojiViewController
This class is the emoji Menu. It contains recently used section and all emoji section. It allows user to select from either one
- **viewDidLoad()**: initialization for EmojiViewController view
- **setupEmojiModels()**: setup and append emoji models name and ID
- **setupRecentModels()**: setup pre-populated emojis for "RECENTLY USED"
- **numberOfSections(in collectionView: UICollectionView) -> Int**: returns number of collections sections
- **collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int**: returns numbers of cells in each section
- **collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell**: returns a configured cell object that corresponds to the specified item in the collection view. 
- **func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize**: returns customized cell size.
- **collectionView(collecitonView: UICollectionView, numberOfItemsInSection section: Int) -> Int**: returns the number of items in each section
- **collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize**: returns customized header size
- **collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView**: returns header label
- **collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)**: poping up user selected emoji mode from the menu and change recently used emoji list.

### ChangeEmojiDelegate
- **changeEmoji(emoji: Emoji)**：function to change emoji 
- **getUpdatedList()->[Emoji]**：returns updated list of recently used emoji


### ModeButton
This class is emoji button in EditState
- **init(frame: CGRect)**: class initialization
- **init?(coder aDecoder: NSCoder)**: an initializer using the data in decoder
- **initButton()**: initialization for Emoji Button. setup button image
- **buttonPressed()**: activate or deactivate emoji Button
- **activateButton(imageName: String)**: activate emoji Button. change button image
- **deactivateButton(imageName: String)**: deactivate emoji Button. change button image

### ListHeaderView
This class is customizing header text in section view in EmojiViewController 
### MenuCollectionViewCell
This class is customizing ModelImage in emoji menu cell in EmojiViewController 
### Emoji
This class is for Emoji Model
- **init(name: String, ID: String)**-: initialize emoji model with its name and ID



	


	
	
	
	
	
	

