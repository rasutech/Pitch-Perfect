//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by LakshmiNarayanan Raju on 01/12/15.
//  Copyright © 2015 rasutech. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder:AVAudioRecorder!
    @IBOutlet weak var recordingStart: UILabel!
    @IBOutlet weak var recordingIcStop: UIButton!
    @IBOutlet weak var recordingIcStart: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    var recordingPaused = false
    
    @IBOutlet weak var recordingIcPause: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startRecording(sender: AnyObject) {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let recordingName = "pitch_perfect.aac"
        let pathArray = [dirPath,recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray);
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            /* Found audioSetting Sample from Internet */
            let audioSettings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000.0,
                AVNumberOfChannelsKey: 1 as NSNumber,
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
            ]
            audioRecorder = try AVAudioRecorder(URL: filePath!, settings: audioSettings)
            
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.record()
            
        } catch {
            print("Exception")
        }
        recordingIcPause.hidden = false;
        recordingIcStart.hidden = true;
        recordLabel.hidden = true;
        recordingIcStop.hidden = false;
        recordingStart.hidden = false;
    }

    @IBAction func stopRecording(sender: AnyObject) {

        recordingIcStop.hidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        }
        catch {
            
        }
        recordingIcPause.hidden = true
        recordingStart.hidden = true
        recordingIcStart.hidden = false
        recordLabel.hidden = false
    }
    
    @IBAction func recordingPause(sender: AnyObject) {
        if recordingPaused {
            recordingIcPause.imageView?.image = UIImage(contentsOfFile: "pause.png")
            recordingPaused = false
            audioRecorder.record()
        } else {
            recordingIcPause.imageView?.image = UIImage(contentsOfFile: "resume.png")
            recordingPaused = true
            audioRecorder.pause()
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        let recordedAudio = RecordedAudio()
        if(flag) {
            recordedAudio.recordedFilePath = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if ( segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsController = segue.destinationViewController as! PlaySoundsController
            let data = sender as! RecordedAudio
            playSoundsVC.recordedAudio = data
        }
    }
}
