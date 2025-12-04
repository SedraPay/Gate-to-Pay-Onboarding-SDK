//
//  CircularProgressBarView.swift
//  Sample
//
//  Created by Amani on 23/12/2025.
//


import UIKit

class CircularProgressBarView: UIView {

    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var timer: Timer?
    private var totalTime = 60
    private var elapsedTime  = 0

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup View
    private func setupView() {
        createCircularPath()
    }

    private func createCircularPath() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                        radius: bounds.width / 2,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 1.5 * CGFloat.pi,
                                        clockwise: true)

        // Track layer
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        // Progress layer
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.blue.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    // MARK: - Start Countdown
    func startCountdown(duration: Int) {
        totalTime = duration
        elapsedTime = 0
        progressLayer.strokeEnd = 0

        // Timer updates progress layer only
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func updateProgress() {
        if elapsedTime < totalTime {
            elapsedTime += 1
            let progress = Double(elapsedTime) / Double(totalTime) // Use floating-point division
            progressLayer.strokeEnd = CGFloat(progress)
        } else {
            timer?.invalidate()
        }
    }

}
