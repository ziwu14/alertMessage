//
//  mapPageViewController.swift
//  pageVC
//
//  Created by ZIHAO WU on 10/30/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import UIKit

//MARK: - UIPageViewController

class mapPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    lazy var viewControllerList: [UIViewController] = { // list of pages
        let sb = UIStoryboard(name: "Home", bundle: nil) //associate Main.storyboard
        let vc1 = sb.instantiateViewController(identifier: "map1ViewController")
        let vc2 = sb.instantiateViewController(identifier: "map2ViewController")
        return [vc1, vc2]
    }()

    var pageControl = UIPageControl()//page dots
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource = self //datasouce which is inherited from UIPageViewControllerDataSource
        //present 1st page
        if let firstVC = viewControllerList.first {
            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        //these two are required for the UIPageControl/page dots
        self.delegate = self
        setUpPageControl()
        
        
        
    }
    
    
    //UIPageControl
    func setUpPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY-300, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = viewControllerList.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .blue
        self.view.addSubview(pageControl)
    }
    
    //MARK: - UIPageViewControllerDataSource
    //view controller before @ previous VC
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else {return nil}
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {return nil}
        
        guard viewControllerList.count > previousIndex else {return nil}
        
        return viewControllerList[previousIndex]
    }
    
    //view controller after @ next VC
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else {return nil}
        
        let nextIndex = (vcIndex == viewControllerList.count - 1) ? 0 : vcIndex + 1
        
        guard viewControllerList.count != nextIndex else {return nil}
        
        guard viewControllerList.count > nextIndex else {return nil}
        
        return viewControllerList[nextIndex]
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


//MARK: - UIPageViewControllerDelegate

extension mapPageViewController: UIPageViewControllerDelegate {
    //set animation on the UIPageController when switch between pages
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = viewControllerList.firstIndex(of: pageContentViewController)!
    }
}

