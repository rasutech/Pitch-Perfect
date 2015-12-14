//
//  PlaySoundsController.swift
//  Pitch Perfect
//
//  Created by LakshmiNarayanan Raju on 05/12/15.
//  Copyright © 2015 rasutech. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsController: UIViewController {
    
    var audioPlayer:AVAudioPlayer!
    var echoPlayer:AVAudioPlayer!

    var audioEnginer:AVAudioEngine!
    var url:NSURL!
    var recordedAudio:RecordedAudio!
    var audioFile:AVAudioFile!
    var reverbPlayers:[AVAudioPlayer] = []
    let N:Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
        try audioPlayer = AVAudioPlayer(contentsOfURL: recordedAudio.recordedFilePath,fileTypeHint: nil);
        try echoPlayer = AVAudioPlayer(contentsOfURL: recordedAudio.recordedFilePath,fileTypeHint: nil);
        audioEnginer = AVAudioEngine()
        try audioFile = AVAudioFile(forReading: recordedAudio.recordedFilePath)
        for i in 0...N {
            let temp = try AVAudioPlayer(contentsOfURL: recordedAudio.recordedFilePath,
                    fileTypeHint: nil)
                reverbPlayers.append(temp)
            reverbPlayers[i] = temp
        }
            
        }
        catch {
            print("AVPlayer Initialisation Failure")
        }
        
        if (audioPlayer != nil) {
            audioPlayer.enableRate = true;
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlow(sender: AnyObject) {
        /* Set Rate to Minimum and Play Sound */
        playAudio(0.5)
        
    }
    
    @IBAction func playChipMunk(sender: AnyObject) {
        playVariablePitch(1000)
    }
    
    @IBAction func playDarthVader(sender: AnyObject) {
        playVariablePitch(-1000)
    }
    
    func playVariablePitch(pitch:Float) {
        audioPlayer.stop()
        audioEnginer.stop()
        audioEnginer.reset()
        let avPlayNode = AVAudioPlayerNode()
        audioEnginer.attachNode(avPlayNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEnginer.attachNode(changePitchEffect)
        
        audioEnginer.connect(avPlayNode, to: changePitchEffect, format: nil)
        audioEnginer.connect(changePitchEffect, to: audioEnginer.outputNode, format: nil)
        avPlayNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do {
            try audioEnginer.start()
            avPlayNode.play();
        }
        catch {
            print("Audio Engine did not start")
        }
    }

    @IBAction func playFast(sender: AnyObject) {
        /* Set Rate to Maximum and Play Sound */
        playAudio(2.0)
    }
    
    func playAudio(rate:float_t) {
        if (audioPlayer != nil) {
            if ( audioPlayer.playing) {
                audioPlayer.stop()
            }
            audioPlayer.currentTime = 0.0
            audioPlayer.rate = rate
            audioPlayer.play()
        }
        else {
            print("Audio Player Reference not found")
        }
        
    }
    
    @IBAction func playReverberation(sender: AnyObject) {
        let delay:NSTimeInterval = 0.02
        for i in 0...N {
            let curDelay:NSTimeInterval = delay*NSTimeInterval(i)
            let player:AVAudioPlayer = reverbPlayers[i]
            //M_E is e=2.718...
            //dividing N by 2 made it sound ok for the case N=10
            let exponent:Double = -Double(i)/Double(N/2)
            let volume = Float(pow(Double(M_E), exponent))
            player.volume = volume
            player.playAtTime(player.deviceCurrentTime + curDelay)
        }
        
    }
    
    @IBAction func playEcho(sender: AnyObject) {
        let delay:NSTimeInterval = 0.1;
        playAudio(1)
        
        echoPlayer.stop()
        echoPlayer.currentTime = 0.0
        echoPlayer.volume = 0.8
        echoPlayer.playAtTime(delay)
        
    }
    
    @IBAction func stopPlaying(sender: AnyObject) {
        if (audioPlayer != nil && audioPlayer.playing) {
            audioPlayer.stop()
        }
        if (echoPlayer != nil && echoPlayer.playing) {
            echoPlayer.stop()
        }
        for i in 0...N {
            let player:AVAudioPlayer = reverbPlayers[i]
            if (player.playing) {
                player.stop()
            }
        }
    }

}
