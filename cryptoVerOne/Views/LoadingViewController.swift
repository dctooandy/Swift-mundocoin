//
//  LoadingViewController.swift
//  cryptoVerOne
//
//  Created by AndyChen on 2022/5/4.
//


import Foundation
import Lottie
import UIKit
import RxCocoa
import RxSwift
class LoadingViewController:BaseViewController {
    static private let share = LoadingViewController()
    
    enum Mode {
        case success
        case fail
        case question
    }
    private let bgView = UIView(color: UIColor.black.withAlphaComponent(0.3))
    private let loadingView: AnimationView = {
        let view = AnimationView(name:"mucoin_loading")
        view.loopMode = LottieLoopMode.loop
        view.animationSpeed = 1
        return view
    }()
    private let errorView: AnimationView = {
        let view = AnimationView(name:"mucoin_error")
        view.loopMode = LottieLoopMode.playOnce
        view.animationSpeed = 1
        return view
    }()
    private let questionView: AnimationView = {
        let view = AnimationView(name:"mucoin_question")
        view.loopMode = LottieLoopMode.playOnce
        view.animationSpeed = 1
        return view
    }()
    private let sucessView: AnimationView = {
        let view = AnimationView(name:"mucoin_sucess")
        view.loopMode = LottieLoopMode.loop
        view.animationSpeed = 1
        return view
    }()
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 5
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(bgView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        view.addSubview(questionView)
        view.addSubview(sucessView)
        view.addSubview(titleLabel)
        bgView.frame = view.frame
        loadingView.frame.size = CGSize(width: 200, height: 200)
        loadingView.center = view.center
        errorView.frame = loadingView.frame
        questionView.frame = loadingView.frame
        sucessView.frame = loadingView.frame
        titleLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(loadingView.snp.bottom).offset(25)
            maker.width.equalTo(300)
            maker.centerX.equalToSuperview()
        }
        loadingView.play()
        sucessView.isHidden = true
        errorView.isHidden = true
        questionView.isHidden = true
        titleLabel.alpha = 0
    }
    static func show() {
//        share.initState()
        share.dismiss(animated: false) {
            
        }
        DispatchQueue.main.async {
            if share.loadingView.isAnimationPlaying { return }
            share.loadingView.isHidden = false
            share.loadingView.play()
            share.modalPresentationStyle = .overCurrentContext
            share.modalTransitionStyle = .crossDissolve
            if share.isBeingPresented == false
            {
                UIApplication.topViewController()?.present(share, animated: true, completion: nil)                
            }
        }
    }
    static func dismiss() -> Observable<Void>{
        let future = PublishSubject<Void>()
        share.loadingView.isHidden = true
        share.dismiss(animated: false, completion: {
            future.onNext(())
            share.initState()
        })
        return future.asObservable()
    }
    
    static func action(mode:Mode , title:String) -> Observable<Void>{
        let future = PublishSubject<Void>()
        share.loadingView.stop()
        share.loadingView.isHidden = true
        switch mode {
        case .success:
            share.sucessView.isHidden = false
            share.sucessView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce, completion: {_ in share.initState()})
        case .fail:
            share.errorView.isHidden = false
            share.errorView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce, completion: {_ in share.initState()})
        case .question:
            share.questionView.isHidden = false
            share.questionView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce, completion:  {_ in share.initState()})
        }
        share.titleLabel.text = title
        UIView.animate(withDuration: 0.25) {
            share.titleLabel.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            share.dismiss(animated: true, completion: {
                future.onNext(())
            })
        }
        return future.asObserver()
    }
    private func initState(){
        loadingView.isHidden = true
        sucessView.isHidden = true
        errorView.isHidden = true
        questionView.isHidden = true
        errorView.stop()
        sucessView.stop()
        questionView.stop()
        titleLabel.alpha = 0
        titleLabel.text = ""
    }
    
    
}
