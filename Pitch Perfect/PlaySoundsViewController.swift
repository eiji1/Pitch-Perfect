//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by eiji on 2015/03/11.
//  Copyright (c) 2015 Udacity & Eiji. All rights reserved.
//

import UIKit
import AVFoundation

/**
View controller for PlaySoundsView. This class controls playing audio data filtered by various effects: Chipmunk, DarthVader, Slow, Fast, Reverb, and Echo. (Returning to previous RecordSoundsView is possible by the NavigationContoller feature.)
*/
final class PlaySoundsViewController: UIViewController {

	//--------------------------------------------//
	// models
	
	/// received audio data sent from RecordSoundsViewController
	private var receivedAudio:RecordedAudio!
	/// audio file object for playing
	private var audioFile:AVAudioFile!
	
	//--------------------------------------------//
	// controllers
	
	private var audioPlayer :AVAudioPlayer!
	private var audioEngine:AVAudioEngine!

	// logging function for debugging
	private func log(message: AnyObject?, line: Int = __LINE__, function :String = __FUNCTION__) {
		print("At \(line) in \(function), \(message)")
	}
	
	/**
	Setter for RecordedAudio instance
	
	- parameter audio: received audio data
	- returns: none
	*/
	final func setRecordedAudio(audio:RecordedAudio) {
		receivedAudio = audio
	}
	
	//------------------------------------------------//
	// view transitsions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		//!! Task 2: legacy code has been removed.
		
		audioPlayer = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
		audioPlayer.enableRate = true
		
		audioEngine = AVAudioEngine()
		audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		// when leave this scene, stop playing audio
		stopAudioPlayers()
	}
	
	//------------------------------------------------//
	// memory handling
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	//------------------------------------------------//
	// play various sounds
	
	/**
	The action from Fast play button. The playback rate is larger than normal case.
	
	- parameter sender: the originaly pushed button
	- returns: none
	*/
	@IBAction func playFastSound(sender: UIButton) {
		stopAudioPlayers()
		audioPlayer.rate = 1.5
		audioPlayer.play()
	}
	
	/**
	The action from Slow play button. The playback rate is smaller than normal case.
	
	- parameter sender: the originaly pushed button
	- returns: none
	*/
	@IBAction func playSlowSound(sender: UIButton) {
		stopAudioPlayers()
		audioPlayer.rate = 0.5
		audioPlayer.play()
	}
	
	/**
	The action from Chipmunk effect button. It makes high pitch sound from originally recorded audio data.
	
	- parameter sender: the originaly pushed button
	- returns: none
	*/
	@IBAction func playChipmunkAudio(sender: UIButton) {
		let changePitchEffect = AVAudioUnitTimePitch()
		// set high pitch value in cents, where semitone corresponds to 100 cents
		changePitchEffect.pitch = 1000.0
		playSoundsWithAudioEffects(changePitchEffect)
	}
	
	/**
	The action from Chipmunk effect button. It makes low pitch sound from originally recorded audio data.
	
	- parameter sender: the originaly pushed button
	- returns: none
	*/
	@IBAction func playDarthvaderAudio(sender: UIButton) {
		let changePitchEffect = AVAudioUnitTimePitch()
		// set low pitch value in cents, where semitone corresponds to 100 cents
		changePitchEffect.pitch = -1000.0
		playSoundsWithAudioEffects(changePitchEffect)
	}

	
	/**
	The action on pressed reverb button. This method performs reverb effect to the recorded audio data. (exceed specification)
	
	- parameter sender: the originaly pushed button
	- returns: none
	*/
	@IBAction func playReverbSounds(sender: UIButton) {
		// reverb effect
		let reverb = AVAudioUnitReverb()
		let preset = AVAudioUnitReverbPreset.LargeHall
		reverb.loadFactoryPreset(preset)
		reverb.wetDryMix = 50
		
		playSoundsWithAudioEffects(reverb)
	}
	
	/**
	The action on pressed echo button. This method performs echo/delay effect to the recorded audio data. (exceed specification)
	
	- parameter sender: the originaly pushed button
	- returns: none
	*/
	@IBAction func playEchoSounds(sender: UIButton) {
		// delay effect
		let delay = AVAudioUnitDelay()
		delay.delayTime = 0.5
		delay.feedback = 60
		delay.wetDryMix = 50
		
		playSoundsWithAudioEffects(delay)
	}
	
	/**
	This method performs specified effect to the recorded audio data.
	
	- parameter filter: The additional audio effect
	- returns: none
	*/
	private func playSoundsWithAudioEffects(effect:AVAudioUnit) {
		stopAudioPlayers()
		audioEngine.reset()
		
		// create audio processing nodes
		let audioPlayerNode = AVAudioPlayerNode()
		// register audio processing nodes to the engine
		audioEngine.attachNode(audioPlayerNode)
		audioEngine.attachNode(effect)
		
		// connect nodes and construct audio processing graph
		audioEngine.connect(audioPlayerNode, to: effect, format: nil)
		audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
		
		// load audio data from given audio file
		audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
		do {
			try audioEngine.start()
		} catch _ {
		}
		
		audioPlayerNode.play()
	}
	
	/**
	The action on pressed stop button. This method stops playing current audio data.
	
	- parameter pitch: specified pitch value shifted from original height
	- returns: none
	*/
	@IBAction func stopSound(sender: AnyObject) {
		stopAudioPlayers()
	}
	
	/**
	Actually stopping both of audio recorder and audio engine. Next audio play is available after called this method and stopped current audio play.
	
	- parameter none:
	- returns: none
	*/
	private func stopAudioPlayers()
	{
		audioPlayer.stop()
		audioPlayer.currentTime = 0
		audioEngine.stop()           // !! Task 3
		audioEngine.reset()
	}
}
