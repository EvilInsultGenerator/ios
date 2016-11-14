//
//  DKSettingsVC.swift
//  Evil Insult
//
//  Created by Dmitri Kalinaitsev on 05/11/2016.
//  Copyright © 2016 Dmitri Kalinaitsev. All rights reserved.
//

import UIKit
import Firebase

class DKSettingsVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // UI Elements
    @IBOutlet weak var languagePicker: UIPickerView!
    
    // Variables and Constants
    let languageArray = ["Deutsch", "Ελληνικά", "English", "Español", "Français", "Русский", "Kiswahili"]
    let languageCodesArray = ["de", "el", "en", "es", "fr", "ru", "sw"]
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add option to swipe open the menu
        self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        
        // Prepare language picker
        let index = languageCodesArray.index(of: UserDefaults.standard.string(forKey: Constants.kSelectedLanguage)!)
        languagePicker.selectRow(index!, inComponent: 0, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Save selected language settings
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Language Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        UserDefaults.standard.set(languageCodesArray[row], forKey: Constants.kSelectedLanguage)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = languageArray[row]
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    // MARK: Actions
    @IBAction func toggleMenu(_ sender: UIButton) {
        self.revealViewController().revealToggle(animated: true)
    } // Opens or closes the menu
}
