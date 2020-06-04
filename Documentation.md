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


	
	
	
	


	


	
	
	
	
	
	

