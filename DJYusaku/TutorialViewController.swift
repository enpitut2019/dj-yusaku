//
//  TutorialViewController.swift
//  DJYusaku
//
//  Created by Yuu Ichikawa on 2019/12/19.
//  Copyright © 2019 Yusaku. All rights reserved.
//

import UIKit

class TutorialViewController: UIPageViewController {
    
    private var tutorialContents: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        let firstTutorial  = storyboard!.instantiateViewController(identifier: "TutorialFirstViewController")  as! TutorialFirstViewController
        let secondTutorial = storyboard!.instantiateViewController(identifier: "TutorialSecondViewController") as! TutorialSecondViewController
        let thirdTutorial  = storyboard!.instantiateViewController(identifier: "TutorialThirdViewController")  as! TutorialThirdViewController
        let fourthTutorial = storyboard!.instantiateViewController(identifier: "TutorialFourthViewController") as! TutorialFourthViewController
        
        tutorialContents = [firstTutorial,
                            secondTutorial,
                            thirdTutorial,
                            fourthTutorial]
        
        self.setViewControllers([tutorialContents[0]],
                                direction: .forward,
                                animated: true,
                                completion: nil)
        
    }

}

// MARK: - UIPageViewControllerDatasource

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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return tutorialContents.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

// MARK: - TutorialFirstViewController

class TutorialFirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK: - TutorialSecondViewController

class TutorialSecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK: - TutorialThirdViewController

class TutorialThirdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK: - TutorialFourthViewController

class TutorialFourthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
