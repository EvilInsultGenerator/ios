//
//  DKNavigationController.swift
//  Evil Insult
//
//  Created by Dmitri Kalinaitsev on 02/11/16.
//  Copyright © 2016 Dmitri Kalinaitsev. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class DKNavigationController: UITableViewController, MFMailComposeViewControllerDelegate {

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            // Home
            FIRAnalytics.logEvent(withName: "home_button_clicked", parameters: nil)

        case 1:
            // Proposal
            FIRAnalytics.logEvent(withName: "send_proposal_email_clicked", parameters: nil)
            sendEmail(withContent: "Hej fuckers,<br /><br />please add this beauty:<br /><br />insult: ...<br />language: ...<br />comment (optional): ...<br /><br />...", toEmail: "marvin@evilinsult.com", withSubject: "Evil Insult Generator Proposal")
            
        case 2:
             // Facebook
            let appUrl = (URL(string: "fb://profile/6348463702260866974")!)
            let webUrl = (URL(string: "https://www.facebook.com/EvilInsultGenerator/")!)
            if UIApplication.shared.canOpenURL(appUrl) {
                FIRAnalytics.logEvent(withName: "facebook_app_launched", parameters: nil)
                UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
                FIRAnalytics.logEvent(withName: "facebook_website_launched", parameters: nil)
            }
            
        case 3:
            // Twitter
            let appUrl = (URL(string: "twitter://user?screen_name=__E__I__G__")!)
            let webUrl = (URL(string: "https://twitter.com/__E__I__G__")!)
            if UIApplication.shared.canOpenURL(appUrl) {
                FIRAnalytics.logEvent(withName: "twitter_app_launched", parameters: nil)
                UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
                FIRAnalytics.logEvent(withName: "twitter_website_launched", parameters: nil)
            }
            
        case 4:
            // Newsletter
            UIApplication.shared.open(URL(string: "https://evilinsult.com/newsletter/")!, options: [:], completionHandler: nil)
            FIRAnalytics.logEvent(withName: "newsletter_website_opened", parameters: nil)
            
        case 5:
            // Contact Us
            sendEmail(withContent: "Marvin, fuck you!", toEmail: "marvin@evilinsult.com", withSubject: "Evil Insult Generator Contact")
            FIRAnalytics.logEvent(withName: "contact_us_button_clicked", parameters: nil)
            
        case 6:
            // Website
            UIApplication.shared.open(URL(string: "https://evilinsult.com/")!, options: [:], completionHandler: nil)
            FIRAnalytics.logEvent(withName: "website_opened", parameters: nil)
            
        case 7:
            // Legal
            UIApplication.shared.open(URL(string: "https://evilinsult.com/legal.html")!, options: [:], completionHandler: nil)
            FIRAnalytics.logEvent(withName: "legal_link_clicked", parameters: nil)
            
        case 8:
            // Settings
            FIRAnalytics.logEvent(withName: "settings_button_clicked", parameters: nil)
            
        default:
            self.revealViewController().revealToggle(animated: true)
        }
    }
    
    // MARK: Functions
    func sendEmail(withContent: String, toEmail: String, withSubject: String) {
        
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([toEmail])
                mail.setSubject(withSubject)
                mail.setMessageBody(withContent, isHTML: true)
                present(mail, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Cannot send mail at this time", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    } // Sends an e-mail with the specified content
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    } // Dismisses the mail.app when user is done with it
}
