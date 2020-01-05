//
//  TutorialViewController.swift
//  DJYusaku
//
//  Created by Hayato Kohara on 2020/01/05.
//  Copyright © 2020 Yusaku. All rights reserved.
//

import UIKit
import SnapKit

class TutorialViewController: UIViewController {
    
    private var pageViewController: UIPageViewController!
    private var tutorialContents: [UIViewController] = []
    @IBOutlet weak var pageControl: UIPageControl!
    private var indexOfPendingContent: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstTutorial  = storyboard!.instantiateViewController(identifier: "TutorialFirstViewController")  as! TutorialFirstViewController
        let secondTutorial = storyboard!.instantiateViewController(identifier: "TutorialSecondViewController") as! TutorialSecondViewController
        let thirdTutorial  = storyboard!.instantiateViewController(identifier: "TutorialThirdViewController")  as! TutorialThirdViewController
        let fourthTutorial = storyboard!.instantiateViewController(identifier: "TutorialFourthViewController") as! TutorialFourthViewController
        
        self.tutorialContents = [firstTutorial,
                                 secondTutorial,
                                 thirdTutorial,
                                 fourthTutorial]
        
        // UIPageViewControllerの設定
        self.pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                       navigationOrientation: .horizontal,
                                                       options: nil)
        self.pageViewController.delegate   = self
        self.pageViewController.dataSource = self
        self.pageViewController.setViewControllers([tutorialContents[0]],
                                                   direction: .forward,
                                                   animated: true,
                                                   completion: nil)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.view.snp.makeConstraints { [unowned self] (make) -> Void in
            make.width.equalTo(self.view.safeAreaLayoutGuide)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.pageControl.snp.top)
        }
        
        // PageControlを前面に表示する
        self.view.bringSubviewToFront(self.pageControl)
        self.pageControl.numberOfPages = self.tutorialContents.count
        self.pageControl.currentPage   = 0
    }

}

// MARK: - UIPageViewControllerDataSource

extension TutorialViewController: UIPageViewControllerDataSource {
    
    // ページを戻す方向の遷移
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = tutorialContents.firstIndex(of: viewController) else { return nil }
        
        let prev = index == 0 ? nil : tutorialContents[index-1]
        
        return prev
    }
    
    // ページを進める方向の遷移
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = tutorialContents.firstIndex(of: viewController) else { return nil }
        
        let next = index ==  tutorialContents.count-1 ? nil : tutorialContents[index+1]
        
        return next
    }
    
}

// MARK: - UIPageViewControllerDelegate

extension TutorialViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let content = pendingViewControllers[0] as! TutorialContentType
        self.indexOfPendingContent = content.indexOfTutorialContent
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.pageControl.currentPage = self.indexOfPendingContent
        }
    }
    
}

// MARK: - TutorialContentViewController

protocol TutorialContentType {
    var indexOfTutorialContent: Int { get }
}

// MARK: - TutorialFirstViewController

class TutorialFirstViewController: UIViewController, TutorialContentType {
    var indexOfTutorialContent: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK: - TutorialSecondViewController

class TutorialSecondViewController: UIViewController, TutorialContentType {
    var indexOfTutorialContent: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK: - TutorialThirdViewController

class TutorialThirdViewController: UIViewController, TutorialContentType {
    var indexOfTutorialContent: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK: - TutorialFourthViewController

class TutorialFourthViewController: UIViewController, TutorialContentType {
    var indexOfTutorialContent: Int = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
