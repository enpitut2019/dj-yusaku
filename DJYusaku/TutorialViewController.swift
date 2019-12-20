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
        
        let firstTutorial = storyboard!.instantiateViewController(identifier: "TutorialFirstViewController") as! TutorialFirstViewController
        let secondTutorial = storyboard!.instantiateViewController(identifier: "TutorialSecondViewController") as! TutorialSecondViewController
        
        tutorialContents = [firstTutorial, secondTutorial]
        
        self.setViewControllers([tutorialContents[0]],
                                direction: .forward,
                                animated: true,
                                completion: nil)
        
    }

}

// MARK: - UIPageViewControllerDatasource

extension TutorialViewController: UIPageViewControllerDataSource{
    
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
