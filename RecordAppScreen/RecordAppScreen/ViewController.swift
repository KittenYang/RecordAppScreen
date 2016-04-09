//
//  ViewController.swift
//  RecordAppScreen
//
//  Created by KittenYang on 16/4/10.
//  Copyright © 2016年 KittenYang. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {

  @IBOutlet weak var snapView: UIView!
  
  var animator: UIDynamicAnimator!
  var snapBehavior: UISnapBehavior?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTapGesture))
    view.addGestureRecognizer(tap)
    animator = UIDynamicAnimator(referenceView: self.view)
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: #selector(ViewController.startRecording))
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  private func alert(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(action)
    self.presentViewController(alert, animated: true, completion: nil)
  }

}

// MARK : handle action

extension ViewController {
  @objc private func handleTapGesture(gesture: UITapGestureRecognizer) {
    let point = gesture.locationInView(self.view)
    if let snap = snapBehavior {
      animator.removeBehavior(snap)
    }
    snapBehavior = UISnapBehavior(item: snapView, snapToPoint: point)
    animator.addBehavior(snapBehavior!)
  }
  
  @objc private func startRecording() {
    let recorder = RPScreenRecorder.sharedRecorder()
    recorder.delegate = self;
    
    recorder.startRecordingWithMicrophoneEnabled(true) { (error) -> Void in
      if let error = error {
        print(error.localizedDescription)
        self.alert(error.localizedDescription)
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: #selector(ViewController.stopRecording))
      }
    }
  }
  
  @objc private func stopRecording() {
    let recorder = RPScreenRecorder.sharedRecorder()
    recorder.stopRecordingWithHandler { (previewController, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
        self.alert(error.localizedDescription)
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: #selector(ViewController.startRecording))
        if let preview = previewController {
          preview.previewControllerDelegate = self
          self.presentViewController(preview, animated: true, completion: nil)
        }
      }
    }
  }
}

extension ViewController: RPScreenRecorderDelegate {
  func screenRecorderDidChangeAvailability(screenRecorder: RPScreenRecorder) {
    print("screen recorder did change availability")
  }
  
  func screenRecorder(screenRecorder: RPScreenRecorder, didStopRecordingWithError error: NSError, previewViewController: RPPreviewViewController?) {
    print("screen recorder did stop recording : \(error.localizedDescription)")
  }
}

extension ViewController: RPPreviewViewControllerDelegate {
  func previewControllerDidFinish(previewController: RPPreviewViewController) {
    print("preview controller did finish")
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func previewController(previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
    print("preview controller did finish with activity types : \(activityTypes)")
    if activityTypes.contains("com.apple.UIKit.activity.SaveToCameraRoll") {
      // video has saved to camera roll
    } else {
      // cancel
    }
  }
}
