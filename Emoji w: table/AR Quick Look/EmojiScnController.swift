

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
    lazy var pathName = "Models.scnassets/" + name + "/" + modelName

    var session: ARSession {
          return sceneView.session
      }
    override func viewDidLoad() {
        super.viewDidLoad()
    // Set the view's delegate
        sceneView.delegate = self
    // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    // Create a new scene
        let scene = SCNScene()

    // Set the scene to the view
        sceneView.scene = scene

        guard let modelScene = SCNScene(named: "Models.scnassets/bandage/bandage.obj") else {
            print("file does not exist!")
            fatalError()
        }
        ObjNode =  modelScene.rootNode.childNode(withName: name!, recursively: true)
//        sceneView.scene.rootNode.addChildNode(ObjNode)
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
//-------------------------------------------------------------------------------
//        guard let touch = touches.first else {
//            print("Unable to identify touches on any plane. Ignoring interaction...")
//            return
//        }
//        let touchPoint = touch.location(in: sceneView)
//        print("Touch happened at point: \(touchPoint)")
//        self.initializeNode()
//       }
//-------------------------------------------------------------------------------
        let location = touches.first!.location(in:sceneView)
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult] = sceneView.hitTest(location, options: hitTestOptions)
        if let hit = hitResults.first {
            if let node = getParent(hit.node) {
              node.removeFromParentNode()
              return
            }
          }
        // find a feature point at the touch location and add an ARAnchor to it
        let hitResultsFeaturePoints: [ARHitTestResult] =
                sceneView.hitTest(location, types: .featurePoint)
        if let hit = hitResultsFeaturePoints.first {
          sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
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

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
      if !anchor.isKind(of: ARPlaneAnchor.self) {
//        node.addChildNode(self.ObjNode)
//        DispatchQueue.main.async {
            let modelClone = self.ObjNode.clone()
            modelClone.position = SCNVector3Zero
//
            // Add model as a child of the node
           node.addChildNode(modelClone)
//          }
      }
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


