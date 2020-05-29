//
//  ViewController.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 28/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import UIKit

import UIKit
import Speech


class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var micIcon: UIImageView!
    
    let saySomething = "Say something, I'm listening!"

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_IN"))
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var viewModel: SpeechViewModel = SpeechViewModel()
    var uttereanceArray: [UtterenceDTO] = []
    var emptyView: UILabel = UILabel()
    let button:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "mic.slash.fill")
        
        return view
    }()
    
    var micOn : Bool = false{
        didSet{
            if micOn{
                AVAudioSession.sharedInstance().requestRecordPermission { (success) in
                    if !success {
                        self.showAlertForMicroPhoneAccess()
                        return
                    } else {
                        self.micIcon.image = UIImage(systemName: "mic.fill")
                                do{
                                    self.textField.text = nil
                                    try SpeechManager.shared.startRecording()//self.startRecording()
                                }catch(let error){
                                    print("error is \(error.localizedDescription)")
                                }
                    }
                }
            }
            else{
                SpeechManager.shared.stopRecording()
                micIcon.image = UIImage(systemName: "mic.slash.fill")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
        SpeechManager.shared.delegate = self
        getPermissions()
        guard SFSpeechRecognizer.authorizationStatus() == .authorized
        else {
            print("guard failed...")
            return
        }
        
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
    }
    
    func buildUI()
    {
        micIcon.image = UIImage(systemName: "mic.slash.fill")
        micIcon.tintColor = UIColor.black.withAlphaComponent(0.6)
        textField.layer.borderColor = UIColor.gray.withAlphaComponent(0.8).cgColor
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        let searchImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(searchTapped))
        self.searchImageView.addGestureRecognizer(searchImageTapGesture)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(micTapped(tapGestureRecognizer:)))
        self.micIcon.addGestureRecognizer(tapGestureRecognizer)
        
        tableView.register(SpeechTextTableViewCell.defaultNib, forCellReuseIdentifier: SpeechTextTableViewCell.defaultNibName)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource =  self
        tableView.delegate = self
        textField.delegate = self
        textField.returnKeyType = .done
        tableView.tableFooterView = UIView()
        emptyView.text = "No Data Present.."
        emptyView.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        emptyView.textColor = .lightText
        tableView.backgroundView = emptyView
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    @objc func searchTapped() {

    }

    @objc func micTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        tappedImage.image = UIImage(systemName: "mic.fill")
        micOn = !micOn
    }
    
    func getPermissions(){
        SFSpeechRecognizer.requestAuthorization{authStatus in
            OperationQueue.main.addOperation {
               switch authStatus {
                    case .authorized:
                        print("authorised..")
                    default:
                        print("none")
               }
            }
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uttereanceArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SpeechTextTableViewCell.defaultNibName, for: indexPath) as? SpeechTextTableViewCell {
            cell.labelText.text = uttereanceArray[indexPath.row].text
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if uttereanceArray.count > indexPath.row {
            self.textField.text = uttereanceArray[indexPath.row].text
            self.view.endEditing(true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {return false}
        textField.resignFirstResponder()
        self.saveText(text: text)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        emptyTable()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && range.length == 1 {
            emptyTable()
        }
        return true
    }
    
    @objc func textChanged() {
        guard let text = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {return}
        self.viewModel.getDataMatchedBy(query: text) { (dtos) in
            self.uttereanceArray = self.searchBasedOnWords(txt: text, array: dtos)
            self.reloadData()
        }
    }
    
    func emptyTable() {
        self.uttereanceArray = []
        self.reloadData()
    }
    
    
}

@available(iOS 10.0, *)
extension ViewController:SpeechManagerDelegate {
    func showAlertForMicroPhoneAccess() {
        DispatchQueue.main.async {
            self.showGoToSettingsAlert()
        }
    }
    
    func didStartedListening(status:Bool)
    {
        if status
        {
            UIView.animate(withDuration: 0.3) {
                //self.textField.text = self.saySomething
            }
            //SpeechManager.shared.speak(text: self.saySomething)
        }
    }

    func didReceiveText(text: String)
    {
        self.textField.text = text
        
        if text != self.saySomething
        {
            //Show clear button
        }
    }
    
    func didFinishSentence(isFinished: Bool) {
        if let text = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            self.saveText(text: text)
            self.micOn = !micOn
        }
        
    }
    
    func saveText(text: String) {
        self.viewModel.saveData(word: text) { (model) in
            self.viewModel.getDataMatchedBy(query: text) { (dtos) in
                self.uttereanceArray = self.searchBasedOnWords(txt: text, array: dtos)
                self.reloadData()
            }
        }
    }
    
    func searchBasedOnWords(txt: String, array: [UtterenceDTO]) -> [UtterenceDTO] {
        let filteredData = array.filter { (model) -> Bool in
            guard let title = model.text else { return false}
            let patterns = createRegEx(pattern: txt)
            return self.searchAnyTextsInList(movieTitle: title, searchRegExArray: patterns)
        }
        return filteredData
    }
    
    func searchAnyTextsInList(movieTitle: String, searchRegExArray: String) -> Bool {
        var found = false
        if let range = movieTitle.range(of: searchRegExArray, options: [.regularExpression,.caseInsensitive]) {
            found = true
        }
        return found
        
    }
    
    func createRegEx(pattern: String) -> String{
        let words = pattern.components(separatedBy: " ")
        var regexArray: [String] = []
        var regex = ""
        words.map {
            regex = "(.*\\b\($0)\\b.*|\\b\($0).*)"
            regex += ""
        }
        return regex
    }
    
    func showGoToSettingsAlert() {
        let alertView =  UIAlertController(title: "Could not get Access to Microphone.. :(", message: "Please go to iOS Settings > Privacy > Microphone to allow access to your Microphone.", preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "Settings" , style: UIAlertAction.Style.default, handler: { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                })
            }
        })
        alertView.addAction(action)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) in
            self.micOn = false
        })
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
    }
}
