//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by eiji on 2015/03/08.
//  Copyright (c) 2015 Udacity & Eiji. All rights reserved.
//

import UIKit
import AVFoundation

/**
Controller for RecordSoundsView. This class manages whole recording processes such as
recording, stopping, pausing, and resuming operations. It controls button visibilities and instruction message on static text. When the recording is finished, current scene moves to the PlaySoundsView and passes the recorded audio data to the next scene.
*/
final class RecordSoundsViewController: UIViewController , AVAudioRecorderDelegate{
	
	//--------------------------------------------//
	// views
	
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var stopButton: UIButton!
	@IBOutlet weak var recordingStatusLabel: UILabel!
	@IBOutlet weak var pauseResumeButton: UIButton!
	
	// string assets for views  !! Task 4
	
	/// text description before recording
	private let textBeforeRecording = "Tap to Record"
	/// text description on recording
	private let textOnRecording = "Recording in Progress..."
	
	//--------------------------------------------//
	// models
	
	/// recorded audio data such as output sound file path.
	private var recordedAudio :RecordedAudio!
	
	//--------------------------------------------//
	// controllers
	
	private var audioRecorder :AVAudioRecorder!
	/// whether recording process is paused or not
	private var isRecorderPaused = false
	
	/// segue identifier string
	private let SegueOnStopRecording = "stopRecording"
	
	// logging function for debugging
	private func log(message: AnyObject?, line: Int = __LINE__, function :String = __FUNCTION__) {
		print("At \(line) in \(function), \(message)")
	}
	
	//------------------------------------------------//
	// view transitsions
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		resetLayouts()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == SegueOnStopRecording {
			// pass recorded audio data to the PlaySoundsViewController
			let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
			let recordedAudioData = sender as! RecordedAudio
			playSoundsVC.setRecordedAudio(recordedAudioData)
		}
	}
	
	//------------------------------------------------//
	// memory handling
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//------------------------------------------------//
	// recording
	
	/**
	The action from microphone button is recording audio data with microphone device.
	
	- parameter sender: the originaly pushed button
	- returns: none
	*/
	@IBAction func recordAudio(sender: UIButton) {
		// stop and pause/resume button will apper.
		stopButton.hidden = false
		pauseResumeButton.hidden = false
		recordButton.enabled = false
		
		// change static text
		recordingStatusLabel.text = textOnRecording
	
		let filePath = getRecordingFilePath()
		// setup recorder object
		let session = AVAudioSession.sharedInstance()
		do {
			try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
		} catch _ {
		}
		
		audioRecorder = try? AVAudioRecorder(URL:filePath, settings:[:])
		audioRecorder.delegate = self
		audioRecorder.meteringEnabled = true
		audioRecorder.prepareToRecord()
		
		// actually start recording
		audioRecorder.record()
	}
	
	/**
	Getting sound file path in which recorded data is stored temporarily
	
	- parameter none:
	- returns: recorded sound file path as url
	*/
	private final func getRecordingFilePath() -> NSURL {
		// get temp directory
		let tmpFileDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
		// create a timestamp
		let currentDateTime = NSDate()
		let formatter = NSDateFormatter()
		formatter.dateFormat = "ddMMyyyy-HHmmss"
		// make recording name from datetime
		let recordFileName = formatter.stringFromDate(currentDateTime)+".wav"
		// create file path finally
		let pathArray = [tmpFileDirPath, recordFileName]
		let filePath = NSURL.fileURLWithPathComponents(pathArray)
		log(filePath)
		return filePath!
	}
	
	/**
	The action on pressed stop button. The recording process will be stopped.
	
	- parameter sender: The stop button
	- returns: none
	*/
	@IBAction func stopAudio(sender: UIButton) {
		// stop audio session
		let session = AVAudioSession.sharedInstance()
		do {
			try session.setActive(false)
		} catch _ {
		}
		audioRecorder.stop()
	}
	
	func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
		if flag {
			recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
			// move to next scene
			self.performSegueWithIdentifier(SegueOnStopRecording, sender: recordedAudio)
		}
		else {
			log("audio recording failed.")
		}
		
		isRecorderPaused = false
		// go back to the first status
		resetLayouts()
	}

	/**
	The action on pressed pause or resume button. The recording process will be paused or resumed respectively. The pause and resume buttons are toggled each other. (exceed specification)
	
	- parameter sender: Pause or resume button
	- returns: none
	*/
	@IBAction func pauseResumeRecording(sender: UIButton) {
		if isRecorderPaused {
			// toggle pause and resume button
			pauseResumeButton.setImage(UIImage(named:"pause_2x.png"), forState: UIControlState.Normal)
			// resume recording
			audioRecorder.record()
			isRecorderPaused = false
		}
		else {
			// toggle pause and resume button
			pauseResumeButton.setImage(UIImage(named:"play_2x.png"), forState: UIControlState.Normal)
			// pause recording
			audioRecorder.pause()
			isRecorderPaused = true
		}
	}
	
	/**
	Reset UI layout to the initial state. The stop and pause buttons are hidden and record button	becomes enabled. The static text shows the first message.
	- parameter none:
	- returns: none
	*/
	private func resetLayouts() {
		stopButton.hidden = true
		
		// return to pause button if current status is resuming
		pauseResumeButton.setImage(UIImage(named:"pause_2x.png"), forState: UIControlState.Normal)
		pauseResumeButton.hidden = true

		recordButton.enabled = true
		recordingStatusLabel.text = textBeforeRecording
	}

}

