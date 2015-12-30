//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by eiji on 2015/03/15.
//  Copyright (c) 2015 Udacity & Eiji. All rights reserved.
//

import Foundation

/// A RecordedAudio class represents audio data of recorded sound in the RecordSoundsViewController. This class stores information about the recorded audio data, and share it among several scenes.
final class RecordedAudio :NSObject{
	var filePathUrl:NSURL!
	var title:String!
	
	/**
	constructor
	
	- parameter filePathUrl: recorded audio file path as url
	- parameter title: recording title
	- returns: none
	*/
	init(filePathUrl:NSURL, title:String){ // !! Task1
		self.filePathUrl = filePathUrl
		self.title = title
	}
}