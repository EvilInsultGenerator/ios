//
//  ViewController.swift
//  Evil Insult
//
//  Created by Dmitri Kalinaitsev on 26/10/16.
//  Copyright © 2016 Dmitri Kalinaitsev. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase


// MARK: Constants
struct Constants2 {
    static let kAppInstalledFirstTime = "kAppInstalledFirstTime"
    static let kSelectedLanguage = "kSelectedLanguage"
    static let kDeviceScreen = "kDeviceScreen"
}

class ViewController2: UIViewController {
    
    // MARK: UI Elements
    @IBOutlet weak var insultTextView: UITextView!
    @IBOutlet weak var generateInsultButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var menuButton: UIButton!
    
    
    // MARK: Variables
    var currentInsult = ""
    var fetchedInsult = ""
    let fetchInsultThread = DispatchQueue.init(label: "insultFetcher")

    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // 1. Check if this app has previously been installed on the device
//        if UserDefaults.standard.bool(forKey: Constants.kAppInstalledFirstTime) != true {
//            // Send statistics
//            UserDefaults.standard.set(true, forKey: Constants.kAppInstalledFirstTime)
//            FIRAnalytics.logEvent(withName: "unique_devices", parameters: nil)
//            
//            // Prepare default insults label
//            UserDefaults.standard.set("en", forKey: Constants.kSelectedLanguage)
//            
//            // Force settings to synchronise
//            UserDefaults.standard.synchronize()
//        }
//
//        // 2. Fetch & Display an initial Insult
//        currentInsult = getInsult()
//        if currentInsult == "Error!\nNo active internet connection" {
//            insultTextView.textColor = UIColor.yellow
//        }
//        insultTextView.text = currentInsult
//        self.setupInsult(textView: insultTextView!)
//        
//        // 3. Stop and hide the loading indicator if it is animating
//        if loadingIndicator.isAnimating == true {
//            loadingIndicator.stopAnimating()
//        }
//        
//        // 4. Make the generate button have rounded corners
//        self.generateInsultButton.layer.cornerRadius = 4.0
//        
//        // 5. Add gesture for swiping from left to open the menu
//        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    
    // MARK: Actions
    @IBAction func toggleMenu(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    } // Opens or closes the menu
    
    @IBAction func generateInsult(_ sender: UIButton) {
        
        FIRAnalytics.logEvent(withName: "generate_insult_button_clicked", parameters: nil)
        
        self.fetchInsultThread.async {
            
            self.fetchedInsult = self.getInsult()
            
            if self.fetchedInsult != "Error!\nNo active internet connection" {
                
                if self.currentInsult == self.fetchedInsult {
                    
                    self.toggleIndicator()
                    
                    OperationQueue.main.addOperation {
                        self.generateInsultButton.isEnabled = false
                    }
                    
                    repeat {
                        self.fetchedInsult = self.getInsult()
                    } while self.fetchedInsult == self.currentInsult
                    
                    OperationQueue.main.addOperation {
                        self.insultTextView.textColor = UIColor.white
                        self.insultTextView!.text = self.fetchedInsult
                        self.currentInsult = self.fetchedInsult
                        self.setupInsult(textView: self.insultTextView)
                        self.generateInsultButton.isEnabled = true
                    }
                    
                    self.toggleIndicator()
                    
                } else {
                    
                    OperationQueue.main.addOperation {
                        self.insultTextView.textColor = UIColor.white
                        self.insultTextView!.text = self.fetchedInsult
                        self.currentInsult = self.fetchedInsult
                        self.setupInsult(textView: self.insultTextView)
                        self.generateInsultButton.isEnabled = true
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    self.insultTextView.textColor = UIColor.yellow
                    self.insultTextView!.text = self.fetchedInsult
                    self.currentInsult = self.fetchedInsult
                    self.setupInsult(textView: self.insultTextView)
                    self.generateInsultButton.isEnabled = true
                }
            }
        }
    } // Generates an insult an updates the view on button click
    
    @IBAction func shareButtonClicked(sender: AnyObject)
    {
        if currentInsult != "" && currentInsult != "Error!\nNo active internet connection" {
            
            FIRAnalytics.logEvent(withName: "share_button_clicked", parameters: nil)
            
            let activityVC = UIActivityViewController(activityItems: [currentInsult], applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.assignToContact, UIActivityType.openInIBooks, UIActivityType.postToVimeo, UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.saveToCameraRoll]
            self.present(activityVC, animated: true, completion: nil)
        } else {
            return
        }
    } // Action to allow user to share an insult
    
    // MARK: Functions
    func setupInsult(textView: UITextView!) {
        // Setup textView contents and adjust it's size accordingly
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        // Draw border
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        textView.layer.borderWidth = 2
        textView.clipsToBounds = true
    } // This function takes care of how the Insult is displayed on user screen
    
    func toggleIndicator() {
        OperationQueue.main.addOperation {
            if self.loadingIndicator.isAnimating {
                self.loadingIndicator.stopAnimating()
            } else {
                self.loadingIndicator.startAnimating()
            }
        }
    } // Convinience function to switch the animating indicator on or off
    
    func getInsult() -> String {
        
        var newInsult = ""
        
        do {
            let urlString = "http://evilinsult.com/generate_insult.php?lang=" + UserDefaults.standard.string(forKey: Constants.kSelectedLanguage)!
            print(urlString)
            newInsult = try String(contentsOf: URL.init(string: urlString)!)
        } catch {
            
            let alert = UIAlertController(title: "Error", message: "No active internet connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return "Error!\nNo active internet connection"
        }
        
        return newInsult
    } // Fetch insult from the internet
}
