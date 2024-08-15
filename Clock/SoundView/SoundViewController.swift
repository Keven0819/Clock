//
//  SoundViewController.swift
//  Clock
//
//  Created by imac-2627 on 2024/8/8.
//

import UIKit
import AVFoundation

protocol SoundViewControllerDelegate: AnyObject {
    func didSelectSound(_ soundName: String)
}

class SoundViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Property
    weak var delegate: SoundViewControllerDelegate?
    let sounds = ["馬林巴琴", "鬼畜", "雷達", "sunkis trust me", "Huu"]
    var selectedSoundIndex: Int = 0
    var audioPlayer: AVAudioPlayer?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        title = "提示聲"
        tableView.register(UINib(nibName: "SoundTableViewCell", bundle: nil), forCellReuseIdentifier: SoundTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneTapped))
    }
    
    // MARK: - IBAction
    
    @objc func doneTapped() {
        delegate?.didSelectSound(sounds[selectedSoundIndex])
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Function
    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("無法播放音效: \(error.localizedDescription)")
        }
    }
}

// MARK: - Extensions

extension SoundViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundTableViewCell", for: indexPath) as! SoundTableViewCell
        cell.lbTest.text = sounds[indexPath.row]
        cell.accessoryType = indexPath.row == selectedSoundIndex ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSoundIndex = indexPath.row
        tableView.reloadData()
        playSound(named: sounds[indexPath.row])
    }
}
