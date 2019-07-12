//
//  ViewController.swift
//  BusAR
//


import UIKit
import SceneKit
import ARKit

class AugmentedController: UIViewController, ARSCNViewDelegate {
//view controller
    @IBOutlet var sceneView: ARSCNView!
    var bussesData:[QRCodeData] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        
        // initialize a scene to present
        let scene = SCNScene(named: "BusDataAR.scnassets/simple.scn")!
        // Set the scene to the view, its like a constructor, it is seeting the scene for what will happen
        sceneView.scene = scene

      
       

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //view such as the screen design etc will appear

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)


    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            self.setBussesDataIntoAugmentedSpace()
        //function calls, lets you do backend manipulation of the data
    }
    
   
    
    // Set maximum Four busses data into AR Space
    private func setBussesDataIntoAugmentedSpace(){
        // busses is more then 3
        if self.bussesData.count > 3 {
            // set Data on .dae model one by one
            for i in 0..<4{
                self.setBoardBusBy(BusCount: i+1, busNo: self.bussesData[i].bus ?? "", time: self.bussesData[i].bus_time ?? "", name: self.bussesData[i].direction ?? "")
            }
        }else{
            // set Data on .dae model one by one
            for i in 0..<self.bussesData.count{
                self.setBoardBusBy(BusCount: i+1, busNo: self.bussesData[i].bus ?? "", time: self.bussesData[i].bus_time ?? "", name: self.bussesData[i].direction ?? "")
            }
        }// if you only have 3 or less than 3 buses in your data it will sort and display on the screen
    }
    
    // set data into specific bus .dae model.
    private func setBoardBusBy(BusCount busCount:Int,busNo:String,time:String,name:String){
        DispatchQueue.global(qos: .userInteractive).async {
            // Get all Nodes Of Scene
            for node in self.sceneView.scene.rootNode.childNodes{
                // check if it related bus node by bus count.
                if node.name == "board\(busCount)"{
                    
                    // Get Bus Number node
                    let textNodeOfSn = node.childNode(withName: "sn", recursively: false)?.childNode(withName: "text", recursively: false)
                    if let textGeometry = textNodeOfSn!.geometry as? SCNText {
                        // set Bus No into text node
                        textGeometry.string = busNo
                    }

                    // Get Bus Time node
                    let textNodeOfTitle = node.childNode(withName: "time", recursively: false)?.childNode(withName: "text", recursively: false)
                    if let textGeometry = textNodeOfTitle!.geometry as? SCNText {
                        // set Bus time into text node
                        textGeometry.string = time
                    }
                    
                    // Get Bus direction node
                    let textNodeOfDescription = node.childNode(withName: "direction", recursively: false)?.childNode(withName: "text", recursively: false)
                   // set Bus direction into text node
                    if let textGeometry = textNodeOfDescription!.geometry as? SCNText {
                        
                        textGeometry.string = name
                    }
                }
                
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session, the screen will go away
        sceneView.session.pause()
    }

   
    // MARK: - ARSCNViewDelegate

/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        return node
    }
*/

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

//
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        }

    @IBAction func backAction(_ sender: Any) {
        
        // return to QR Screen
        DispatchQueue.main.async {
            //this will return to orginal scanning screen
            self.dismiss(animated: true, completion: nil)
           // self.navigationController?.popViewController(animated: true)
        }
    }
}


