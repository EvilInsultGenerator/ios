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
import SystemConfiguration

// MARK: Constants
struct Constants {
    static let kAppLoadedSecondTime = "kAppLoadedSecondTime"
    static let kSelectedLanguage = "kSelectedLanguage"
    static let kDeviceScreen = "kDeviceScreen"
    static let kLastFetchDate = "kLastFetchDate"
    
    // Laguage Arrays
    static let kENInsults = "kENInsults"
    static let kDEInsults = "kDEInsults"
    static let kESInsults = "kESInsults"
    static let kFRInsults = "kFRInsults"
    static let kRUInsults = "kRUInsults"
    static let kSWInsults = "kSWInsults"
    static let kELInsults = "kELInsults"
    
    // Language codes
    static let kENCode = "en"
    static let kFRCode = "fr"
    static let kDECode = "de"
    static let kESCode = "es"
    static let kELCode = "el"
    static let kRUCode = "ru"
    static let kSWCode = "sw"
}

class ViewController: UIViewController {
    
    // MARK: UI Elements
    @IBOutlet weak var insultTextView: UITextView!
    @IBOutlet weak var generateInsultButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    
    // MARK: Variables
    var currentInsult = ""
    let fetchInsultThread = DispatchQueue.init(label: "insultFetcher")

    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the generate button have rounded corners
        self.generateInsultButton.layer.cornerRadius = 4.0
        
        // Add gesture for swiping from left to open the menu
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // App launched for first time
        if UserDefaults.standard.bool(forKey: Constants.kAppLoadedSecondTime) != true {
            // App loading for the first time on this device
            
            // Prepare default insults label
            UserDefaults.standard.set(Constants.kENCode, forKey: Constants.kSelectedLanguage)
            
            // Send statistics
            UserDefaults.standard.set(true, forKey: Constants.kAppLoadedSecondTime)
            FIRAnalytics.logEvent(withName: "unique_devices", parameters: nil)
            
            if isConnectedToNetwork() == true {
                // There is network
                let array = self.fetchInsult(forLanguage: Constants.kENCode)
                if array.count != 0 {
                    UserDefaults.standard.set(array, forKey: Constants.kENInsults)
                    UserDefaults.standard.synchronize()
                    self.currentInsult = randomInsultFromArray(key: Constants.kENInsults)
                    self.updateInsultTextView(withText: self.currentInsult)

                } else {
                    FIRCrashMessage("Error fetching insult on first launch")
                    showAlert(withText: "Error fetching insult. Please try again", andButton: "OK", withTitle: "Error")
                }
            } else {
                // No network
                
                currentInsult = "Error!\nNo active internet connection"
                insultTextView.textColor = UIColor.yellow
                insultTextView.text = currentInsult
                self.updateInsultTextViewAppearance()
                self.showAlert(withText: "You need internet connection if you are running the app for the first time", andButton: "OK", withTitle: "Error")
            }
        } else {
            // App loading for the second time on this device or after switching language
            self.showInsult()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
        // Fetch insults if needed
        if UserDefaults.standard.value(forKey: Constants.kLastFetchDate) == nil {
            UserDefaults.standard.set(Date(), forKey: Constants.kLastFetchDate)
            UserDefaults.standard.synchronize()
            fetchInsultThread.async {
                self.fetchAllInsults()
            }
        } else if dayPassed() == true {
            UserDefaults.standard.set(Date(), forKey: Constants.kLastFetchDate)
            UserDefaults.standard.synchronize()
            fetchInsultThread.async {
                self.fetchAllInsults()
            }
        }
        
        // Timer for checking for new insults
        Timer.scheduledTimer(timeInterval: 3600,
                             target: self,
                             selector: #selector(checkForNewInsults),
                             userInfo: nil,
                             repeats: true)
        
    } // All insults will be fetched once the view is already on screen
    
    // MARK: Actions
    @IBAction func toggleMenu(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    } // Opens or closes the menu
    @IBAction func generateInsult(_ sender: UIButton) {
        showInsult()
    } // Generate insult button action
    @IBAction func shareButtonClicked(sender: AnyObject) {
        FIRAnalytics.logEvent(withName: "share_button_clicked", parameters: nil)
        let activityVC = UIActivityViewController(activityItems: [insultTextView.text], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.assignToContact, UIActivityType.openInIBooks, UIActivityType.postToVimeo, UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.saveToCameraRoll]
        self.present(activityVC, animated: true, completion: nil)
        
    } // Action to allow user to share an insult
    
    // MARK: - Functions -
    // MARK: Alerts & Errors
    func showAlert(withText text: String, andButton button: String, withTitle title: String) {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    } // Shows an alert to the user
    func throwInternetConnectionErrorInInsultViewAndAlert() {
        OperationQueue.main.addOperation {
            self.currentInsult = "Error!\nNo active internet connection"
            self.insultTextView.textColor = UIColor.yellow
            self.insultTextView.text = self.currentInsult
            self.updateInsultTextViewAppearance()
            self.showAlert(withText: "You need internet connection", andButton: "OK", withTitle: "Error")
        }
    } // Shows a generic no internet connection error

    // MARK: Update Insult view
    func updateInsultTextViewAppearance() {
        OperationQueue.main.addOperation {
            // Setup textView contents and adjust it's size accordingly
            let fixedWidth = self.insultTextView.frame.size.width
            self.insultTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            let newSize = self.insultTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            var newFrame = self.insultTextView.frame
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            self.insultTextView.frame = newFrame
            
            // Draw border
            self.insultTextView.layer.cornerRadius = 5
            self.insultTextView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
            self.insultTextView.layer.borderWidth = 2
            self.insultTextView.clipsToBounds = true
        }
    } // This function takes care of how the Insult is displayed on user screen
    func updateInsultTextView(withText text: String) {
        OperationQueue.main.addOperation {
            self.insultTextView.textColor = UIColor.white
            self.insultTextView!.text = text
            self.currentInsult = text
            self.updateInsultTextViewAppearance()
        }
    } // Replaces content in the Insults text view
    
    // MARK: Updating Insult database
    func fetchInsult(forLanguage lang: String) -> Array<String> {
        var insultsArray = Array<String>()
        do {
            let url = URL.init(string: "https://evilinsult.com/list/" + lang + ".txt")!
            insultsArray = try String(contentsOf: url).components(separatedBy: CharacterSet.newlines)
            
            for insult in insultsArray where insult == "" {
                insultsArray.remove(at: insultsArray.index(of: insult)!)
            }
        } catch {
            // No error handling needed as an empty array is returned
        }
        return insultsArray
    } // Fetch insult for a particular language
    func dayPassed() -> Bool {
        
        var bool = false
        
        let lastFetchedDate = UserDefaults.standard.value(forKey: Constants.kLastFetchDate) as! Date
        let interval = Date().timeIntervalSince(lastFetchedDate)
        
        if interval > 86400 {
            bool = true
        }
        
        return bool
    } // Checks if enough time has passed since last fetch of insults. Insults should not be fetched more than once in 24h
    func randomInsultFromArray(key: String) -> String {
        
        let array = UserDefaults.standard.array(forKey: key)
        let totalInsults = UInt32((array?.count)!)
        let rand = Int(arc4random_uniform(totalInsults))
        return array?[rand] as! String
    } // Returns a random value from the specified array of insults
    func showInsult() {
        
        // Checks if the array has data
        func isNilOrEmpty(arrayKey: String) -> Bool {
            
            var bool = true
            if UserDefaults.standard.array(forKey: arrayKey)?.count != 0 && UserDefaults.standard.array(forKey: arrayKey) != nil {
                bool = false
            }
            return bool
        }
        
        switch UserDefaults.standard.string(forKey: Constants.kSelectedLanguage)! {
        case Constants.kDECode:
            if isNilOrEmpty(arrayKey: Constants.kDEInsults) == true {
                if isConnectedToNetwork() == true {
                    let array = self.fetchInsult(forLanguage: Constants.kDECode)
                    if array.count != 0 {
                        UserDefaults.standard.set(array, forKey: Constants.kDEInsults)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    throwInternetConnectionErrorInInsultViewAndAlert()
                }
            }
            self.currentInsult = randomInsultFromArray(key: Constants.kDEInsults)
            self.updateInsultTextView(withText: self.currentInsult)
            
        case Constants.kESCode:
            if isNilOrEmpty(arrayKey: Constants.kESInsults) == true {
                if isConnectedToNetwork() == true {
                    let array = self.fetchInsult(forLanguage: Constants.kESCode)
                    if array.count != 0 {
                        UserDefaults.standard.set(array, forKey: Constants.kESInsults)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    throwInternetConnectionErrorInInsultViewAndAlert()
                }
            }
            self.currentInsult = randomInsultFromArray(key: Constants.kESInsults)
            self.updateInsultTextView(withText: self.currentInsult)
            
        case Constants.kFRCode:
            if isNilOrEmpty(arrayKey: Constants.kFRInsults) == true {
                if isConnectedToNetwork() == true {
                    let array = self.fetchInsult(forLanguage: Constants.kFRCode)
                    if array.count != 0 {
                        UserDefaults.standard.set(array, forKey: Constants.kFRInsults)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    throwInternetConnectionErrorInInsultViewAndAlert()
                }
            }
            self.currentInsult = randomInsultFromArray(key: Constants.kFRInsults)
            self.updateInsultTextView(withText: self.currentInsult)
            
        case Constants.kRUCode:
            if isNilOrEmpty(arrayKey: Constants.kRUInsults) == true {
                if isConnectedToNetwork() == true {
                    let array = self.fetchInsult(forLanguage: Constants.kRUCode)
                    if array.count != 0 {
                        UserDefaults.standard.set(array, forKey: Constants.kRUInsults)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    throwInternetConnectionErrorInInsultViewAndAlert()
                }
            }
            self.currentInsult = randomInsultFromArray(key: Constants.kRUInsults)
            self.updateInsultTextView(withText: self.currentInsult)
            
            
        case Constants.kSWCode:
            if isNilOrEmpty(arrayKey: Constants.kSWInsults) == true {
                if isConnectedToNetwork() == true {
                    let array = self.fetchInsult(forLanguage: Constants.kSWCode)
                    if array.count != 0 {
                        UserDefaults.standard.set(array, forKey: Constants.kSWInsults)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    throwInternetConnectionErrorInInsultViewAndAlert()
                }
            }
            self.currentInsult = randomInsultFromArray(key: Constants.kSWInsults)
            self.updateInsultTextView(withText: self.currentInsult)
            
        case Constants.kELCode:
            if isNilOrEmpty(arrayKey: Constants.kELInsults) == true {
                if isConnectedToNetwork() == true {
                    let array = self.fetchInsult(forLanguage: Constants.kELCode)
                    if array.count != 0 {
                        UserDefaults.standard.set(array, forKey: Constants.kELInsults)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    throwInternetConnectionErrorInInsultViewAndAlert()
                }
            }
            self.currentInsult = randomInsultFromArray(key: Constants.kELInsults)
            self.updateInsultTextView(withText: self.currentInsult)
            
        default:
            if isNilOrEmpty(arrayKey: Constants.kENInsults) == true {
                if isConnectedToNetwork() == true {
                    let array = self.fetchInsult(forLanguage: Constants.kENCode)
                    if array.count != 0 {
                        UserDefaults.standard.set(array, forKey: Constants.kENInsults)
                        UserDefaults.standard.synchronize()
                    }
                } else {
                    throwInternetConnectionErrorInInsultViewAndAlert()
                }
            }
            self.currentInsult = randomInsultFromArray(key: Constants.kENInsults)
            self.updateInsultTextView(withText: self.currentInsult)
            
        }
    } // Displays insult in TextView
    func fetchAllInsults() {
        
        OperationQueue.main.addOperation {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        if isConnectedToNetwork() == true {
            // English
            let en = self.fetchInsult(forLanguage: Constants.kENCode)
            if en.count != 0 {
                UserDefaults.standard.set(en, forKey: Constants.kENInsults)
            }
            
            // German
            let de = self.fetchInsult(forLanguage: Constants.kDECode)
            if de.count != 0 {
                UserDefaults.standard.set(de, forKey: Constants.kDEInsults)
            }
            
            // Spanish
            let es = self.fetchInsult(forLanguage: Constants.kESCode)
            if es.count != 0 {
                UserDefaults.standard.set(es, forKey: Constants.kESInsults)
            }
            
            // French
            let fr = self.fetchInsult(forLanguage: Constants.kFRCode)
            if fr.count != 0 {
                UserDefaults.standard.set(fr, forKey: Constants.kFRInsults)
            }
            
            // Russian
            let ru = self.fetchInsult(forLanguage: Constants.kRUCode)
            if ru.count != 0 {
                UserDefaults.standard.set(ru, forKey: Constants.kRUInsults)
            }
            
            // Swhaili
            let sw = self.fetchInsult(forLanguage: Constants.kSWCode)
            if sw.count != 0 {
                UserDefaults.standard.set(sw, forKey: Constants.kSWInsults)
            }
            
            // Greek
            let el = self.fetchInsult(forLanguage: Constants.kELCode)
            if el.count != 0 {
                UserDefaults.standard.set(el, forKey: Constants.kELInsults)
            }
            
            UserDefaults.standard.synchronize()
        }
        
        OperationQueue.main.addOperation {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    } // Fetches insults for all languages and saves them on the device
    func checkForNewInsults() {
        fetchInsultThread.async {
            if self.dayPassed() {
                UserDefaults.standard.set(Date(), forKey: Constants.kLastFetchDate)
                UserDefaults.standard.synchronize()
                self.fetchAllInsults()
            }
        }
    } // Action for timer to check for new insults once every 24 hours
    
    // MARK: Misc
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
    } // Checks whether user device has internet connection or not
}




