//
//  ViewController.swift
//  20200-05-10Study
//
//  Created by Tomoya Tanaka on 2021/05/10.
//

import UIKit

struct PuzzlePoint {
	var tag: Int;
	var point: CGPoint;
	
	init(tag: Int, point: CGPoint) {
		self.tag   = tag
		self.point = point
	}
}

class ViewController: UIViewController {
	let puzzleSize: Int = 300
	var count: Int = 0
	private var initialCenter: CGPoint = .zero
	private var puzzlePoints: [PuzzlePoint] = []
	
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor.black
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "移動させてね"
		label.isUserInteractionEnabled = true
		label.font = UIFont.systemFont(ofSize: 48.0)
		
		return label
	}()
	
	private let parentFrame: UIStackView = {
		let frame = UIStackView()
		frame.axis = .vertical
		frame.distribution = .fillEqually
		frame.alignment = .fill
		frame.translatesAutoresizingMaskIntoConstraints = false
		frame.layer.borderColor = UIColor.systemGreen.cgColor
		frame.layer.borderWidth = 3
		return frame
	}()
	
	private let childFrame: [UIStackView] = {
		let puzzleSize: Int = 300
		var array = [UIStackView]()
		var tagCount = 0
		for i in 1...3 {
			let frame = UIStackView()
			frame.axis = .horizontal
			frame.distribution = .fillEqually
			frame.alignment = .fill
			frame.layer.borderColor = UIColor.systemRed.cgColor
			frame.layer.borderWidth = 3
			frame.translatesAutoresizingMaskIntoConstraints = false
			for j in 1...3 {
				tagCount += 1
				let element = UIView()
				element.frame.size = CGSize(width: puzzleSize / 3, height: puzzleSize / 3)
				element.layer.borderWidth = 3
				element.layer.borderColor = UIColor.systemPink.cgColor
				element.tag = tagCount
				frame.addArrangedSubview(element)
			}
			array.append(frame)
		}
		
		return array
	}()
	
	private let puzzlePieces: [UIImageView] = {
		let puzzleSize: Int = 300
		var array = [UIImageView]()
		
		for i in 1...9 {
			let imageView = UIImageView(image: UIImage(named: "\(i).jpg"))
			imageView.isUserInteractionEnabled = true
			imageView.frame.size = CGSize(width: puzzleSize / 3, height: puzzleSize / 3)
			imageView.tag = i
			imageView.alpha = 0.5
			array.append(imageView)
		}
		return array
	}()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(titleLabel)
		view.addSubview(parentFrame)
		NSLayoutConstraint.activate([
			NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 100),
			NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: parentFrame, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: parentFrame, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
		])
		parentFrame.widthAnchor.constraint(equalToConstant: CGFloat(puzzleSize)).isActive = true
		parentFrame.heightAnchor.constraint(equalToConstant: CGFloat(puzzleSize)).isActive = true
	
		for row in childFrame {
			row.frame.size = CGSize(width: puzzleSize, height: puzzleSize / 3)
			parentFrame.addArrangedSubview(row)
		}
		
		for piece in puzzlePieces {
			let randomX = Double.random(in: 0...400)
			let randomY = Double.random(in: 200...500)
			let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
			piece.addGestureRecognizer(panGestureRecognizer)
			piece.center = CGPoint(x: randomX, y: randomY)

			view.addSubview(piece)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		for subview in parentFrame.subviews {
			for element in subview.subviews {
				let point = subview.convert(element.frame.origin, to: self.view)
				let puzzlePoint = PuzzlePoint(tag: element.tag, point: point)
				print(element.tag, point)
				puzzlePoints.append(puzzlePoint)
			}
		}
	}
	
	
	@objc private func didPan(_ sender: UIPanGestureRecognizer) {
		switch sender.state {
			case .began:
				initialCenter = sender.view!.center
			case .changed:
				let translation = sender.translation(in: view)
				
				sender.view?.center = CGPoint(x: initialCenter.x + translation.x,
											  y: initialCenter.y + translation.y)
			case .ended:
				puzzlePoints.map { puzzlePoint in
					print(puzzlePoint.tag, sender.view!.tag)
					if puzzlePoint.tag == sender.view!.tag {
						let diffX = puzzlePoint.point.x - sender.view!.frame.origin.x
						let diffY = puzzlePoint.point.y - sender.view!.frame.origin.y
						print(diffX, diffY)
						if case -20...20 = diffX, case -10...10 = diffY {
							sender.view!.alpha = 1
							sender.view!.frame.origin = puzzlePoint.point
							sender.view!.isUserInteractionEnabled = false
							let generator = UINotificationFeedbackGenerator()
							generator.notificationOccurred(.success)
							count += 1
							if count == puzzlePoints.count {
								titleLabel.text = "完成"
							}
						}
					}
				}
				break
			case .cancelled:
				print("cancelled")
			default:
				break
		}
	}
	

}

