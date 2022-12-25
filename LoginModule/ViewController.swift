//
//  ViewController.swift
//  LoginModule
//
//  Created by Jose on 16/12/2022.
//

import UIKit
import Combine

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var txtUsername: UITextField! {
        didSet {
            txtUsername.delegate = self
        }
    }
    @IBOutlet weak var txtPassword: UITextField! {
        didSet {
            txtPassword.delegate = self
        }
    }
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            activityIndicatorView.isHidden = true
            activityIndicatorView.startAnimating()
        }
    }
        
    // MARK: Ivars
    var viewModel = ViewModel()
    var subscriptions: Set<AnyCancellable> = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    // MARK: - Actions
    @IBAction func btnSignInDidTap(_ sender: UIButton) {
        viewModel.signIn()
    }
    
    // MARK: - Private
    private func setupBindings() {
        viewModel.$hasError
            .receive(on: DispatchQueue.main)
            .compactMap{ $0 }
            .sink { [weak self] value in
                if value {
                    // Show error
                    let alert = UIAlertController(title: NSLocalizedString("uhoh", comment: ""), message: NSLocalizedString("login-error", comment: ""), preferredStyle: .alert)
                    let action = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default)
                    alert.addAction(action)
                    self?.present(alert, animated: true)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isSigningInPublisher
            .map{!$0}
            .assign(to: \.isHidden, on: activityIndicatorView)
            .store(in: &subscriptions)
        
        viewModel.signingResponsePublisher
            .compactMap{$0}
            .sink { [weak self] value in
                let alert = UIAlertController(title: NSLocalizedString("cool", comment: ""), message: NSLocalizedString(value, comment: ""), preferredStyle: .alert)
                let action = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default)
                alert.addAction(action)
                self?.present(alert, animated: true)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Textfield delegates
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textPublisher
            .sink { [weak self] text in
                if textField == self?.txtUsername {
                    self?.viewModel.username = text
                }
                else {
                    self?.viewModel.password = text
                }
            }
            .store(in: &subscriptions)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtUsername {
            self.txtPassword.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
       
       return true
    }
}


