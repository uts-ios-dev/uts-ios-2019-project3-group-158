//
//  ViewController.swift
//  test222
//
//  Created by Pooria Rashidi on 20/5/19.
//  Copyright © 2019 Pouriya Rashidi. All rights reserved.
//

import UIKit
import AVKit
import Speech
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var startstopButton: UIButton!
    @IBOutlet weak var segmentCtr: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    
    private var speechRecognizer = SFSpeechRecognizer (locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine ()
    var lang: String = "en-US"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        startstopButton.isEnabled = false
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate
        speechRecognizer = SFSpeechRecognizer (locale: Locale.init(identifier: lang))
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print ("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print ("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print ("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.startstopButton.isEnabled = isButtonEnabled
            }
        }
        
    }

    
    
    @IBAction func segmentAct(_ sender: Any) {
        switch segmentCtr.selectedSegmentIndex {
        case 0:
            lang = "en-US"
            break;
        case 1:
            lang = "de-DE"
            break;
        case 2:
            lang = "fr-FR"
            break;
        case 3:
            lang = "es-ES"
            break;
        case 4:
            lang = "it-IT"
            break;
        default:
            lang = "en-US"
            break;
        }
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
    }
    
    
    @IBAction func startStopAct(_ sender: Any) {
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startstopButton.isEnabled = false
            startstopButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            startstopButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            
        } catch {
            print("audioSession properties were not set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: {(result, error) in
            var isFinal = false
            if result != nil {
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.startstopButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            
            try audioEngine.start()
            
        } catch { print("auidoEngine couldnt start because of an error.") }
        
        textView.text = "I am Listening Now ... Say Something!"
    }
    
    
    func speechRecognizer (_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startstopButton.isEnabled = true
        } else {
            startstopButton.isEnabled = false
        }
    }
}
    
    




