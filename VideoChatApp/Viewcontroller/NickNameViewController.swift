//
//  NickNameViewController.swift
//  VideoChatApp
//
//  Created by Nilesh on 08/09/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

import UIKit

class NickNameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nicknameTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegates
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let chatVC = segue.destination as? ChatViewController, let nickName = nicknameTextView.text {
            
            chatVC.nickName = nickName
        }
        
    }

}
