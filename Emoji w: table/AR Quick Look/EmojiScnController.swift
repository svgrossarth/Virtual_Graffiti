

import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO

class EmojiScnController : UIViewController, ARSCNViewDelegate{
    var ObjNode : SCNNode!
    @IBOutlet var sceneView: ARSCNView!

    var name : String! = "bandage"
    let modelExtension = ".obj"
    lazy var modelName = name + modelExtension
    lazy var pathName = "Models.scnassets/" + modelName

    var session: ARSession {
          return sceneView.session
    }

    func setModel(){
        //ModelIO
        guard let emojiScene = SCNScene(named:"Models.scnassets/bandage.scn") else {
            print("model does not exist")
            fatalError()
        }
        ObjNode = emojiScene.rootNode.childNode(withName: "Group50555", recursively: true)
        ObjNode.position = SCNVector3(0, 0, -50)
//        self.sceneView.scene.rootNode.addChildNode(ObjNode!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    // Set the view's delegate
        sceneView.delegate = self
    // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

    // Set the scene to the view
//        guard  let url = Bundle.main.url(forResource: "bandage", withExtension: "scn") else {
//            fatalError("bandage.scn not exit.")
//        }
//        guard let customNode = SCNReferenceNode(url: url) else {
//            fatalError("load bandage error.")
//        }
//        customNode.load()
//        ObjNode.addChildNode(customNode)

//        setModel()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("Unable to identify touches on any plane. Ignoring interaction...")
            return
        }
        let touchPoint = touch.location(in: sceneView)

        self.setModel()
    //add to plane
        let hits = sceneView.hitTest(touchPoint, types: .estimatedHorizontalPlane)
        print(hits.first)
        if hits.count >= 0, let firstHit = hits.first {
               print("Touch happened at point: \(touchPoint)")
            if let anotherNode = ObjNode?.clone() {
                anotherNode.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
                sceneView.scene.rootNode.addChildNode(anotherNode)
            }
        }
    }

    func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
          if node.name == name {
            return node
          } else if let parent = node.parent {
            return getParent(parent)
          }
        }
        return nil
      }

    // MARK: ar scnview delegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor  else { return }
        print("-----------------------> session did add anchor!")
        node.addChildNode(ObjNode)
    }

     func session(_ session: ARSession, didFailWithError error: Error) {
         // Present an error message to the user

     }

     func sessionWasInterrupted(_ session: ARSession) {
         // Inform the user that the session has been interrupted, for example, by presenting an overlay

     }

     func sessionInterruptionEnded(_ session: ARSession) {
         // Reset tracking and/or remove existing anchors if consistent tracking is required

     }


}




