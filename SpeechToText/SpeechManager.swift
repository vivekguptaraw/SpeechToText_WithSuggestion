//
//  SpeechManager.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 28/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import Foundation
import Speech

protocol SpeechManagerDelegate
{
    func didReceiveText(text:String)
    func didStartedListening(status:Bool)
    func didFinishSentence(isFinished: Bool)
    func showAlertForMicroPhoneAccess() 
}

@available(iOS 10.0, *)
class SpeechManager
{
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_IN"))
    private var recognitionTask: SFSpeechRecognitionTask?
    var delegate:SpeechManagerDelegate?
    var utteranceTimer: Timer?
    let sentenceEndTimer: TimeInterval = 2
    static let shared:SpeechManager = {
        let instance = SpeechManager()
        return instance
    }()
    var mostRecentlyProcessedSegmentDuration: TimeInterval = 0

    func startRecording() throws{
        
        mostRecentlyProcessedSegmentDuration = 0
        recognitionTask?.cancel()
        self.recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true

        if #available(iOS 13, *) {
            if speechRecognizer?.supportsOnDeviceRecognition ?? false{
                recognitionRequest.requiresOnDeviceRecognition = true
            }
        }
        delegate?.didStartedListening(status: true)
        self.setTimer()
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            //print("==<>>\(error.debugDescription) \(result.debugDescription)")
            var isFinal = false
            
            if result != nil {
                if let bestranscript = result?.bestTranscription {
                    if let tm = self.utteranceTimer, tm.isValid {
                        print("tm.isValid true")
                            self.delegate?.didReceiveText(text: bestranscript.formattedString)
                        self.utteranceTimer?.invalidate()
                        self.setTimer()
                    } else {
                        print(self.utteranceTimer)
                        print("tm.isValid false")
                        self.delegate?.didFinishSentence(isFinished: true)
                    }
                }
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                print("==> audioEngine Stopped")
            }
        })
    }
    
    func setTimer() {
        utteranceTimer = Timer.scheduledTimer(timeInterval: sentenceEndTimer, target: self, selector: #selector(didFinishUtterance), userInfo: nil, repeats: false)
    }
    
    @objc func didFinishUtterance() {
        self.delegate?.didFinishSentence(isFinished: true)
    }
    
    func stopRecording()
    {
        if audioEngine.isRunning
        {
            
            recognitionRequest?.endAudio()
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }
    
    func speak(text: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .measurement, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setMode(.measurement)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
    }
    
    fileprivate func updateUIWithTranscription(_ transcription: SFTranscription) {
        
    }
}
