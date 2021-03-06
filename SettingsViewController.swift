//
//  SettingsViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import Photos
import FacebookCore
import FacebookLogin

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var tableViewSettings: UITableView!
    @IBOutlet weak var cellImportFromPhotos: UITableViewCell!
    @IBOutlet weak var cellImportFromAita: UITableViewCell!
    @IBOutlet weak var cellFacebook: UITableViewCell!
    @IBOutlet weak var textViewFeedback: UITextView!
    @IBOutlet weak var buttonSendFeedback: UIButton!
    @IBOutlet weak var labelVersion: UILabel!
    
    @IBOutlet weak var imageViewPhotosIcon: UIImageView!
    @IBOutlet weak var imageViewAitaIcon: UIImageView!
    @IBOutlet weak var labelImportFromPhotos: UILabel!
    @IBOutlet weak var labelImportFromAita: UILabel!
    
    
    let sectionsHeaders = ["Import countries".localized(), "Accounts".localized(), "Support and feedback".localized()];
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localized()

//        labelVersion.text = "Version".localized() + " " + "1.1"
        labelVersion.text = " "
        imageViewPhotosIcon.layer.cornerRadius = 5
        imageViewAitaIcon.layer.cornerRadius = 5
        
        labelImportFromPhotos.text = "Import from Photos".localized()
        labelImportFromAita.text = "Import from App in the Air".localized()
        
        cellFacebook.textLabel?.text = "Facebook".localized()
        cellFacebook.detailTextLabel?.text = FacebookHelper.shared.isConnected() ? "Connected".localized() : "Not connected".localized()
        
        textViewFeedback.layer.cornerRadius = 5
        textViewFeedback.layer.borderColor = UIColor.gray.cgColor
        textViewFeedback.layer.borderWidth = 0.5
        textViewFeedback.delegate = self
        
        buttonSendFeedback.setTitle("Send".localized(), for: .normal)
        buttonSendFeedback.layer.cornerRadius = 5
        
        tableViewSettings.delegate = self
        
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
        tapGestureRecognizer.isEnabled = false
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAccountsInfo), name: FacebookHelper.shared.AccountInfoUpdatedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions
    @IBAction func buttonSendFeedbackTapped(_ sender: Any) {
        if textViewFeedback.text.isEmpty {
            StatusBarManager.shared.showCustomStatusBarError(text: "Please write something.".localized())
            textViewFeedback.becomeFirstResponder()
        } else {
            self.performSegue(withIdentifier: "segueToEmailController", sender: nil)
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? EmailController {
            controller.feedbackDelegate = self
            controller.backgroundImage = Bluring.blurBackground(backgroundController: self)
            controller.feedbackText = textViewFeedback.text
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsHeaders[section]
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewSettings.deselectRow(at: indexPath, animated: true)
        if let cell = tableViewSettings.cellForRow(at: indexPath) {
            switch (cell) {
            case cellImportFromPhotos:
                PhotosAccessManager.shared.importVisitedCountries(controller: self)
            case cellFacebook:
                FacebookHelper.shared.login()
            case cellImportFromAita:
                if #available(iOS 10.0, *) {
                    if let accessToken = User.shared.aitaAccessToken, let refreshToken = User.shared.aitaRefreshToken {
                        AitaHelper.shared.getUserCountries(accessToken: accessToken, refreshToken: refreshToken,
                                                           completion:  nil)
                    } else {
                        performSegue(withIdentifier: "segueToAitaLoginController", sender: nil)
                    }
                } else {
                    // Fallback on earlier versions
                }
            default: ()
            }
        }
    }
    
    // MARK: - Notifications
    @objc func updateAccountsInfo() {
        
        UIView.transition(with: cellFacebook.detailTextLabel!,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.cellFacebook.detailTextLabel?.text = FacebookHelper.shared.isConnected() ? "Connected".localized() : "Not connected".localized()
        }, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SettingsViewController: UIGestureRecognizerDelegate {
    @objc func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            textViewFeedback.resignFirstResponder()
            tapGestureRecognizer.isEnabled = false
        }
    }
}

// MARK: - UITextViewDelegate
extension SettingsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        tapGestureRecognizer.isEnabled = true
    }
}

// MARK: - FeedbackDelegate
extension SettingsViewController: FeedbackDelegate {
    func feedbackSuccessfullySent() {
        textViewFeedback.text = ""
    }
}
