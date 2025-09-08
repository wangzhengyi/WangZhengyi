//
//  ViewController.swift
//  HelloWorldApp
//
//  Created for iOS Learning
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Components
    private let helloLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to iOS Learning Journey"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tap Me!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var tapCount = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        view.addSubview(helloLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(tapButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Hello Label
            helloLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            helloLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            helloLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            helloLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Subtitle Label
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: helloLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Tap Button
            tapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tapButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            tapButton.widthAnchor.constraint(equalToConstant: 120),
            tapButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        tapButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        tapCount += 1
        
        // Update UI with animation
        UIView.animate(withDuration: 0.3, animations: {
            self.tapButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.tapButton.transform = .identity
            }
        }
        
        // Update labels based on tap count
        switch tapCount {
        case 1:
            helloLabel.text = "Hello, iOS Developer!"
            subtitleLabel.text = "You tapped \(tapCount) time"
        case 2...5:
            helloLabel.text = "Keep Learning!"
            subtitleLabel.text = "You tapped \(tapCount) times"
        case 6...10:
            helloLabel.text = "You're doing great!"
            subtitleLabel.text = "\(tapCount) taps and counting..."
        default:
            helloLabel.text = "iOS Master in Progress!"
            subtitleLabel.text = "\(tapCount) taps - You're unstoppable!"
        }
    }
}
