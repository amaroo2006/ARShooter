//
//  ViewController.swift
//  ARShooter
//
//  Created by Ansh Maroo on 10/3/19.
//  Copyright © 2019 Mygen Contac. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


enum BitMaskCategory: Int {
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController, SCNPhysicsContactDelegate {

    
    @IBOutlet var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    var power : Float = 50
    var Target: SCNNode?
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        
        guard let pointOfView = sceneView.pointOfView else {return}
        
        let transform = pointOfView.transform
        
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        let position = orientation + location
        
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true)
        bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        
        sceneView.scene.rootNode.addChildNode(bullet)
        
    }
    
    @IBAction func addTargets(_ sender: UIButton) {
        addEgg(x: 5, y: 0, z: -40)
        addEgg(x: 0, y: 0, z: -40)
        addEgg(x: -5,y: 0, z: -40)
    }
    
    func addEgg(x: Float, y: Float, z: Float) {
        let eggScene = SCNScene(named: "art.scnassets/egg.scn")
        let eggNode = (eggScene?.rootNode.childNode(withName: "egg", recursively: false))!
        eggNode.position = SCNVector3(x,y,z)
        
        eggNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode, options: nil))
        eggNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        eggNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        
        sceneView.scene.rootNode.addChildNode(eggNode)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            
            Target = nodeA
            
        }
        
        else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            
            Target = nodeB
            
        }
        
        let confetti = SCNParticleSystem(named: "art.scnassets/Confetti.scnp", inDirectory: nil)
        
        
    }
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
