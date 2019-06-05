//
//  ViewController.swift
//  SpeechTranslatePal
//
//  Created by Pooria Rashidi on 1/6/19.
//  Copyright © 2019 Pouriya Rashidi. All rights reserved.
//

import UIKit
import Speech
import Foundation

class ViewController: UIViewController {
    
    public var speechRecognizer = SFSpeechRecognizer (locale: Locale.init(identifier: "en"))
    public var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    public var recognitionTask: SFSpeechRecognitionTask?
    public var audioEngine = AVAudioEngine ()
    var lang: String = "en"
    var lang2: String = "en"
    
    @IBOutlet weak var startStopButton: UIButton!
    
    @IBAction func startStop(_ sender: Any) {
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startStopButton.isEnabled = false
            startStopButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            startStopButton.setTitle("Stop Recording", for: .normal)
        }
        
        
    }
    @IBAction func translate(_ sender: Any) {
        
        let translator = GoogleTranslate()
        translator.apiKey = "AIzaSyBcCqUyTuUHQTU-cv2mLoicLDHD9_dW2RU"
        
        var params = GoogleTranslateParameters()
        params.source = lang
        params.target = lang2
        params.text = textView.text
        
        translator.translate(params: params) { (result) in
            DispatchQueue.main.async {
                self.translation.text = "\(result)"
            }
        }
        
    }
    
    
    @IBOutlet weak var segmentCtr: UISegmentedControl!
    @IBOutlet weak var segmentCtr2: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var translation: UITextView!

    @IBAction func segmentActFrom(_ sender: Any) {
        
        switch segmentCtr.selectedSegmentIndex {
        case 0:
            lang = "en"
            break;
        case 1:
            lang = "de"
            break;
        case 2:
            lang = "fr"
            break;
        case 3:
            lang = "es"
            break;
        case 4:
            lang = "it"
            break;
        default:
            lang = "en"
            break;
        }
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
    }
    
    
    @IBAction func segmentActTo(_ sender: Any) {
        
        switch segmentCtr2.selectedSegmentIndex {
        case 0:
            lang2 = "en"
            break;
        case 1:
            lang2 = "de"
            break;
        case 2:
            lang2 = "fr"
            break;
        case 3:
            lang2 = "es"
            break;
        case 4:
            lang2 = "it"
            break;
        default:
            lang2 = "en"
            break;
        }
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startStopButton.isEnabled = false
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
                self.startStopButton.isEnabled = isButtonEnabled
            }
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
                
                self.startStopButton.isEnabled = true
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
            startStopButton.isEnabled = true
        } else {
            startStopButton.isEnabled = false
        }
    }
}
    
    
    
    
    

